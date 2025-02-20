# Grid.gd
extends Node3D

var astar: AStar3D = AStar3D.new()

const GRID_WIDTH: int = 10       # Number of cells in the X-direction.
const GRID_HEIGHT: int = 10      # Number of cells in the Z-direction.
const CELL_SIZE: float = 2.0     # Distance between grid points.

func _ready():
	# Initialize grid points.
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var cell_id = _cell_id(x, y)
			var cell_pos = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
			astar.add_point(cell_id, cell_pos)
	
	# Connect adjacent grid points.
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var current_id = _cell_id(x, y)
			var neighbors = [
				Vector2(x + 1, y),
				Vector2(x, y + 1),
				Vector2(x - 1, y),
				Vector2(x, y - 1)
			]
			for neighbor in neighbors:
				if neighbor.x >= 0 and neighbor.x < GRID_WIDTH and neighbor.y >= 0 and neighbor.y < GRID_HEIGHT:
					var neighbor_id = _cell_id(neighbor.x, neighbor.y)
					if not astar.are_points_connected(current_id, neighbor_id):
						astar.connect_points(current_id, neighbor_id, false)
	
	print("Grid and AStar navigation initialized!")
	
	# Create visualizations.
	_create_debug_visualization()

# Computes a unique cell ID based on its (x, y) coordinates.
func _cell_id(x: int, y: int) -> int:
	return x + y * GRID_WIDTH

# Renamed pathfinding function to avoid conflicting with Node.get_path()
func find_path(start_pos: Vector3, target_pos: Vector3) -> PackedVector3Array:
	var start_id = astar.get_closest_point(start_pos)
	var target_id = astar.get_closest_point(target_pos)
	return astar.get_point_path(start_id, target_id)

# Creates debug visualization: grid lines and markers.
func _create_debug_visualization():
	# Create a MeshInstance3D to hold our grid lines.
	var grid_lines_instance = MeshInstance3D.new()
	var im = ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# For each grid cell, draw lines to its right and bottom neighbor.
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var current_id = _cell_id(x, y)
			var current_pos = astar.get_point_position(current_id)
			
			# Draw a line to the right neighbor.
			if x < GRID_WIDTH - 1:
				var right_id = _cell_id(x + 1, y)
				var right_pos = astar.get_point_position(right_id)
				im.surface_set_color(Color.RED)
				im.surface_add_vertex(current_pos)
				im.surface_set_color(Color.RED)
				im.surface_add_vertex(right_pos)
			# Draw a line to the bottom neighbor.
			if y < GRID_HEIGHT - 1:
				var bottom_id = _cell_id(x, y + 1)
				var bottom_pos = astar.get_point_position(bottom_id)
				im.surface_set_color(Color.RED)
				im.surface_add_vertex(current_pos)
				im.surface_set_color(Color.RED)
				im.surface_add_vertex(bottom_pos)
	im.surface_end()
	grid_lines_instance.mesh = im
	add_child(grid_lines_instance)
	
	# Add a small marker (green sphere) for each grid point.
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var cell_pos = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
			_create_marker(cell_pos)

# Creates a small sphere at the given position for debugging.
func _create_marker(marker_position: Vector3):
	var marker_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	marker_instance.mesh = sphere
	
	marker_instance.position = marker_position
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.GREEN
	marker_instance.material_override = mat
	
	add_child(marker_instance)
