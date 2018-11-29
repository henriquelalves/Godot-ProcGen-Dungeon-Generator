var vertices_tree_idx = {}
var vertices = []
var edges_dic = {}
var edges = []

var tree_id_counter = 0

class KeySorter:
	static func sort(a, b):
#		print(a, b)
		if a.x < b.x:
			return true
		elif a.x == b.x and a.y < a.y:
			return true
		return false

class EdgeSorter:
	static func sort(a, b):
		if a["distance"] < b["distance"]:
			return true
		return false

func start(points): # Receive a dictionary of points {vec2:{vec2:true, vec2:true...} ...}
	var ret_edges = []
	vertices = points
	
	# First, get an array of edges {distance, v1, v2}, in distance order
	for p in points.keys():
		vertices_tree_idx[p] = tree_id_counter
		tree_id_counter += 1
		for ps in points[p].keys():
			var key = [p,ps]
			key.sort_custom(KeySorter, "sort")
			edges_dic[key] = {"v1": p, "v2": ps, "distance": p.distance_to(ps)}
	
	edges = edges_dic.values()
	edges.sort_custom(EdgeSorter, "sort")
	
	# For each edge, check if it can connect vertices
	for edge in edges:
		if vertices_tree_idx[edge["v1"]] != vertices_tree_idx[edge["v2"]]:
			change_tree_idx(vertices_tree_idx[edge["v1"]], vertices_tree_idx[edge["v2"]])
			ret_edges.push_back([edge["v1"], edge["v2"]])

	print(ret_edges)
	return ret_edges

func change_tree_idx(id_from, id_to):
	for vertice in vertices:
		if vertices_tree_idx[vertice] == id_from:
			vertices_tree_idx[vertice] = id_to

#func _ready():
#	edges.sort_custom(EdgeSorter, "sort")