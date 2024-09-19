extends Node2D


# Astar grid
@onready var astar_grid = AStarGrid2D.new()
var static_tilemap_layer: TileMapLayer
var static_tile_size: Vector2
var global_center: Vector2
var obst_static_cells: Array[Vector2]
var free_static_cells: Array[Vector2]


func set_astar() -> void:
	# Set up parameters, then update the grid.
	astar_grid.region = static_tilemap_layer.get_used_rect()
	astar_grid.cell_size = static_tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	# I want to fly to Manhattan, so
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	for tile in get_used_static_cells():
		astar_grid.set_point_solid(tile,true)


func get_astar_path(from_position, to_position) -> Array:
	## Double convert to fix offset and global coordinates
	# Position to astar map
	var from = static_tilemap_layer.local_to_map(from_position - global_center)
	var to = static_tilemap_layer.local_to_map(to_position - global_center)
	var arr_ids: Array = astar_grid.get_id_path(from, to)
	# Map coords to global position with shifted center
	var arr_pos: Array[Vector2]
	for i in arr_ids:
		var pos := Vector2(
			global_center + 
			Vector2(i) * static_tile_size + 
			static_tile_size / 2
			)
		arr_pos.append(pos)
	return arr_pos

## Find obstacles via get_collision_polygons_count for each tile
# Because do not use custom data and other monkeyshit
func get_used_static_cells() -> Array[Vector2]:
	var obst_static_cells_array: Array[Vector2]
	var free_static_cells_array: Array[Vector2]
	var all_cells = static_tilemap_layer.get_used_cells()
	# Find corners
	var ax := []
	var ay := []
	for ac in all_cells:
		ax.append(ac.x)
		ay.append(ac.y)
	# Iterate and find obstacles
	for x in range(ax.min(), ax.max()):
		for y in range(ay.min(), ay.max()):
			var ctdata := static_tilemap_layer.get_cell_tile_data(Vector2(x, y))
			if ctdata and ctdata.get_collision_polygons_count(0) > 0:
				obst_static_cells_array.append(Vector2(x, y))
			else:
				free_static_cells_array.append(Vector2(x, y))
	obst_static_cells = obst_static_cells_array
	free_static_cells = free_static_cells_array
	return obst_static_cells_array
	
func get_free_static_cells() -> Array[Vector2]:
	return free_static_cells
