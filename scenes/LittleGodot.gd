extends Node2D

const MIN_DISTANCE = 0.05

onready var target_pos = Vector2()
onready var target_tile = Vector2()

onready var begin_passage = Vector2()
onready var end_passage = Vector2()
onready var moving_empty = false
onready var last_room_ref = null

onready var moving = false
onready var moving_y = false

signal intersected_room
signal create_passage
signal finished

func next_tile():

	
	# Is area2d intersecting something?
	if $Area2D.get_overlapping_bodies().empty():
		emit_signal("create_passage", target_tile)
	elif last_room_ref != $Area2D.get_overlapping_bodies()[0]:
		last_room_ref = $Area2D.get_overlapping_bodies()[0]
		emit_signal("intersected_room", last_room_ref)
#	if not $Area2D.get_overlapping_bodies().empty():
#		if last_room_ref != $Area2D.get_overlapping_bodies()[0]:
#			last_room_ref = $Area2D.get_overlapping_bodies()[0]
#			emit_signal("intersected_room", last_room_ref)
#
#		if moving_empty: # Was moving on empty space
#			moving_empty = false
#			emit_signal("create_passage", begin_passage, end_passage)
#	else:
#		if moving_empty == false: # Just got out of a room
#			moving_empty = true
#			begin_passage.x = target_tile.x # Deep copy vector, why do I need to do this tho
#			begin_passage.y = target_tile.y
#		end_passage.x = target_tile.x
#		end_passage.y = target_tile.y
	
	# Has finished moving?
	if target_tile == target_pos:
		moving = false
		emit_signal("finished")
		return
	
	# New tile to lerp position to
	if target_tile.y == target_pos.y:
#		if not moving_y: # started moving horizontally, checks if needs to create passage
#			if moving_empty:
#				emit_signal("create_passage", begin_passage, end_passage)
#				begin_passage.x = target_tile.x
#				begin_passage.y = target_tile.y
#				end_passage.x = target_tile.x
#				end_passage.y = target_tile.y
#
#			moving_y = true
		target_tile.x += 16 * sign(target_pos.x - position.x)
	else:
		target_tile.y += 16 * sign(target_pos.y - position.y)

func move_to(pos):
	moving = true
	moving_empty = false
	moving_y = false
	target_pos = pos.snapped(Vector2(16,16))
	position = position.snapped(Vector2(16,16))
	target_tile = position

func _physics_process(delta):
	if moving:
		position.x = lerp(position.x, target_tile.x, 0.5)
		position.y = lerp(position.y, target_tile.y, 0.5)
		if position.distance_to(target_tile) < MIN_DISTANCE:
			call_deferred("next_tile")

func _ready():
	pass # Replace with function body.