extends RigidBody2D

var size = Vector2()
var last_pos = position
var selected = false

func _ready():
	pass

func create(s = null):
	if s == null:
		size = Vector2(64 * (0.5 + randf()), 64 * (0.5 + randf())).snapped(Vector2(16,16))
	else:
		size = s
		disable()
		enable_collision_box()
		choose()
		set_physics_process(false)
	$Frame.rect_size = size
	$Tile.rect_size = size
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.extents = Vector2(size.x/2.0, size.y/2.0)
	$CollisionShape2D.position = size/2.0

func choose():
	selected = true
	modulate = Color(1.0, 0.5, 0.8, 1.0)

func enable_collision_box():
#	pass
	$CollisionShape2D.disabled = false
	collision_mask = 0
	collision_layer = 1

func disable():
	$CollisionShape2D.disabled = true
	collision_layer = 0
	sleeping = true

func get_tile_size():
	return size/16.0

func select_main():
	modulate = Color(1.0, 0.1, 0.1, 1.0)

func get_movement():
	global.max_movement = max(global.max_movement, (position-last_pos).length())
	last_pos = position

func _physics_process(delta):
	position = position.snapped(Vector2(16,16))
