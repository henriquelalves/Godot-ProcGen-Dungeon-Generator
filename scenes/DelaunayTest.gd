extends Node2D

onready var Delaunay = preload("res://delaunay_triangulation.gd")
onready var delaunay = null

onready var positions = []
onready var triangles = []

func _ready():
	delaunay = Delaunay.new()

func _draw():
	for p in positions:
		draw_circle(p, 3.0, Color(1.0, 1.0, 0.0))

	for triangle in triangles:
		print(triangle.points[0]*1000, triangle.points[1]*1000, triangle.points[2]*1000)
		draw_line(triangle.points[0]*1000, triangle.points[1]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)
		draw_line(triangle.points[1]*1000, triangle.points[2]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)
		draw_line(triangle.points[2]*1000, triangle.points[0]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			positions.push_back(event.position)
			update()

	if event is InputEventKey and event.is_pressed():
		print("====== STARTING ======")
		triangles = delaunay.bowyer_watson(positions)
#		triangles = Geometry.triangulate_polygon(PoolVector2Array(positions))
		print("====== ENDED ======")
		print(triangles)
		update()