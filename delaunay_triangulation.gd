var triangle_id = 0

func test():
	var new_triangle = triangle.new(0, Vector2(0, 10), Vector2(10, 0), Vector2(10, 10))

func bowyer_watson(pl):
	test()
	
	var point_list = pl.duplicate()
	for i in range(point_list.size()):
		point_list[i] /= 1000.0

	var triangulation = []
	var super_triangle = triangle.new(triangle_id, Vector2(0.4, -0.4), Vector2(-0.8, 1), Vector2(1.6, 1))
	triangle_id += 1
	triangulation.push_back(super_triangle)

	for point in point_list:
		var bad_triangles = []
		for tri in triangulation:
			if tri.is_in_circumcircle(point):
				bad_triangles.push_back(tri)
		var polygon = []
		for tri in bad_triangles:
			for edge in tri.edges:
				if is_edge_shared(bad_triangles, edge) <= 1:
					polygon.push_back(edge)
		
		for tri in bad_triangles:
			remove_triangle(triangulation, tri)

		for edge in polygon:
			var new_tri = triangle.new(triangle_id, edge[0],edge[1],point)
			triangle_id += 1
			triangulation.push_back(new_tri)

	var idx = 0
	for tri_idx in range(triangulation.size()):
		var tri = triangulation[idx]
		if contain_vertex_from_triangle(tri, super_triangle):
			triangulation.remove(idx)
		else:
			idx += 1
	return triangulation 

func contain_vertex_from_triangle(tri1, tri2):
	if contain_vertex_from_point(tri1.points[0], tri2) or\
	contain_vertex_from_point(tri1.points[1], tri2) or\
	contain_vertex_from_point(tri1.points[2], tri2):
		return true
	return false

func contain_vertex_from_point(p, tri):
	if p == tri.points[0] or p == tri.points[1] or p == tri.points[2]:
		return true
	return false

func remove_triangle(triangulation, tri):
	for t in range(len(triangulation)):
		if triangulation[t].id == tri.id:
			triangulation.remove(t)
			return

func is_edge_equal(edge1, edge2):
	if ((edge1[0] == edge2[0]) and (edge1[1] == edge2[1])) or \
	((edge1[0] == edge2[1]) and (edge1[1] == edge2[0])):
		return true
	return false

func is_edge_shared(triangles, edge):
	var counter = 0
	for tri in triangles:
		if (is_edge_equal(tri.edges[0], edge) or \
		is_edge_equal(tri.edges[1], edge) or \
		is_edge_equal(tri.edges[2], edge)):
			counter += 1
	return counter

# Helper class
class triangle:
	var id = 0
	
	var points = []
	var edges = []
	
	func _init(triangle_id, p1, p2, p3):
		id = triangle_id
		set_points(p1, p2, p3)
	
	func set_points(p1, p2, p3):
		if not ccw(p1,p2,p3):
			var temp = p2
			p2 = p3
			p3 = temp
		
		points = [p1, p2, p3]
		edges = [[p1,p2],[p2,p3],[p3,p1]]
	
	func ccw(a, b, c):
		return (b.x - a.x)*(c.y - a.y)-(c.x - a.x)*(b.y - a.y) > 0
	
	func is_in_circumcircle(point):
		var col1 = Vector3(points[0].x - point.x, points[1].x - point.x, points[2].x - point.x)
		var col2 = Vector3(points[0].y - point.y, points[1].y - point.y, points[2].y - point.y)
		var col3 = Vector3(\
		pow((points[0].x - point.x),2.0) + pow((points[0].y - point.y), 2.0),\
		pow((points[1].x - point.x),2.0) + pow((points[1].y - point.y), 2.0),\
		pow((points[2].x - point.x),2.0) + pow((points[2].y - point.y), 2.0))
		var basis = Basis(col1, col2, col3)
		if basis.determinant() > 0.0:
			return true
		return false