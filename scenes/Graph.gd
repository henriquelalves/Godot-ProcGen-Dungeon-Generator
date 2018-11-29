extends Control

enum DRAWING {NO_DRAW, TRIANGLES, SPANNING_TREE}
onready var current_state = DRAWING.NO_DRAW

onready var triangles = []
onready var spanning_tree = []

func clean():
	current_state = DRAWING.NO_DRAW
	update()

func draw_triangles(tri):
	triangles = tri
	current_state = DRAWING.TRIANGLES
	update()

func draw_spanning_tree(st):
	spanning_tree = st
	current_state = DRAWING.SPANNING_TREE
	update()

func _draw():
	
	if current_state == DRAWING.TRIANGLES:
		for triangle in triangles:
	#		print(triangle.points[0], triangle.points[1], triangle.points[2])
			draw_line(triangle.points[0]*1000, triangle.points[1]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)
			draw_line(triangle.points[1]*1000, triangle.points[2]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)
			draw_line(triangle.points[2]*1000, triangle.points[0]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)
	elif current_state == DRAWING.SPANNING_TREE:
		for edge in spanning_tree:
			draw_line(edge[0]*1000, edge[1]*1000, Color(1.0, 0.2, 1.0, 1.0), 2.0, true)