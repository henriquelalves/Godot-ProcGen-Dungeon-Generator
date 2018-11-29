extends Node2D

onready var Room = preload("res://scenes/Room.tscn")

enum STATE {STATE_IDLE, STATE_CREATING_ROOMS, STATE_SEPARATING, STATE_MAIN_ROOMS, STATE_TRIANGULATION, STATE_MIN_SPANNING_TREE, STATE_LITTLE_GODOT, STATE_FINISH}
onready var current_state = STATE.STATE_IDLE
onready var last_working_state = STATE.STATE_IDLE

onready var creating_rooms_tick = 0.0
onready var creating_rooms_tick_limit = 0.01
onready var number_rooms_generating = 40
onready var room_minimum_size = 6.0

onready var main_rooms = []

onready var graph_points = {}

onready var Delaunay = preload("res://delaunay_triangulation.gd")
onready var delaunay = null
onready var triangles = []

onready var Kruskal = preload("res://kruskal.gd")
onready var kruskal = null
onready var min_spanning_tree = []

onready var edge_idx = 0

func _ready():
	randomize()
	
	delaunay = Delaunay.new()
	kruskal = Kruskal.new()
	$LittleGodot.connect("finished", self, "on_littlegodot_finished")
	$LittleGodot.connect("create_passage", self, "on_littlegodot_passage")
	$LittleGodot.connect("intersected_room", self, "on_littlegodot_room")

func on_littlegodot_finished():
	printt("Finished")
	if edge_idx < min_spanning_tree.size():
		$LittleGodot.position = min_spanning_tree[edge_idx][0] * 1000
		$LittleGodot.move_to(min_spanning_tree[edge_idx][1] * 1000)
		edge_idx += 1
	else:
		$LittleGodot.hide()
		idle()

func on_littlegodot_passage(pos):
	printt("Passage", pos)
	var new_room = Room.instance()
	$Rooms.add_child(new_room)
	new_room.position = pos - $Rooms.position
	new_room.create(Vector2(16,16))
#	var new_room = Room.instance()
#	$Rooms.add_child(new_room)
#	if begin.x == end.x:
#		new_room.position = Vector2(begin.x, min(begin.y, end.y)) - $Rooms.position
#		new_room.create(Vector2(32, abs(begin.y - end.y) + 16))
#	else:
#		new_room.position = Vector2(min(begin.x, end.x), begin.y) - $Rooms.position
#		new_room.create(Vector2(abs(begin.x - end.x) + 16, 32))

func on_littlegodot_room(room_ref):
	printt("Room ref", room_ref)
	room_ref.choose()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		next_state()
	
	if event is InputEventKey:
		if event.is_pressed():
			if event.scancode == KEY_SPACE:
				next_state()
		elif event.scancode == KEY_R and event.is_pressed():
			get_tree().change_scene("res://scenes/Main.tscn")

func idle():
	last_working_state = current_state
	current_state = STATE.STATE_IDLE

func next_state():
	if current_state != STATE.STATE_IDLE:
		return
	
	current_state = last_working_state + 1
	
	match current_state:
		STATE.STATE_SEPARATING:
			for child in $Rooms.get_children():
				child.collision_layer = 1
				
		STATE.STATE_MAIN_ROOMS:
			var children = $Rooms.get_children()
			children.shuffle()
			var min_size = round(children.size()*0.5)
			while children.size() > min_size:
				children[0].queue_free()
				children.pop_front()
			
			for child in children:
				child.position = child.position.snapped(Vector2(16.0,16.0))
				if child.get_tile_size().length() > room_minimum_size:
					child.select_main()
					child.raise()
					main_rooms.append(child)
			idle()
		
		STATE.STATE_TRIANGULATION:
			var positions = []
			for room in main_rooms:
				positions.push_back(room.global_position + room.size/2.0)
			triangles = delaunay.bowyer_watson(positions)
			
			# Godot delaunay triangulation implementation is not working, but this
			# is how it's called
#			triangles = Geometry.triangulate_polygon(PoolVector2Array(positions))
			
			$GraphLayer/Graph.draw_triangles(triangles)
			
			for triangle in triangles:
				for point in triangle.points:
					if not graph_points.has(point):
						graph_points[point] = {}
				graph_points[triangle.points[0]][triangle.points[1]] = true
				graph_points[triangle.points[0]][triangle.points[2]] = true
				graph_points[triangle.points[1]][triangle.points[0]] = true
				graph_points[triangle.points[1]][triangle.points[2]] = true
				graph_points[triangle.points[2]][triangle.points[0]] = true
				graph_points[triangle.points[2]][triangle.points[1]] = true
			idle()
		
		STATE.STATE_MIN_SPANNING_TREE:
			min_spanning_tree = kruskal.start(graph_points)
			$GraphLayer/Graph.draw_spanning_tree(min_spanning_tree)
			idle()
		
		STATE.STATE_LITTLE_GODOT:
			$LittleGodot.show()
			for room in $Rooms.get_children():
				room.enable_collision_box()
			
			edge_idx = 0
			$LittleGodot.position = min_spanning_tree[edge_idx][0] * 1000
			$LittleGodot.move_to(min_spanning_tree[edge_idx][1] * 1000)
			edge_idx += 1
		
		STATE.STATE_FINISH:
			for room in $Rooms.get_children():
				if not room.selected:
					room.queue_free()
			$GraphLayer/Graph.clean()

func _physics_process(delta):
	match current_state:
		
		STATE.STATE_CREATING_ROOMS:
			creating_rooms_tick += delta
			if creating_rooms_tick > creating_rooms_tick_limit:
				creating_rooms_tick -= creating_rooms_tick_limit
				var new_room = Room.instance()
				$Rooms.add_child(new_room)
				new_room.create()
				new_room.position = Vector2(randi()%200 - 100, randi()%100 - 50)
				if $Rooms.get_child_count() >= number_rooms_generating:
					idle()
		
		STATE.STATE_SEPARATING:
			global.max_movement = 0.0
			for room in $Rooms.get_children():
				room.get_movement()
			
			if global.max_movement < 0.01:
				for child in $Rooms.get_children():
					child.disable()
				idle()