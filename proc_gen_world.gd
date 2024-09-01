extends Node2D

@onready var g = $loader

# Astar grid
@onready var astar_grid = AStarGrid2D.new()
@onready var ground_tilemap_layer: TileMapLayer = $GroundTileMapLayer
@onready var static_tilemap_layer: TileMapLayer = $StaticTileMapLayer
@onready var tilemap_debug_path: Line2D = $DebugLine2D
var static_tile_size := 64
var tilemap_path := []

@export var chunk_size: int = 512
var half_chunk: int
var quarter_chunk: int

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var gravel: int
var ground: int
var grassg: int
var grassd: int
var cente: float = 0.25
var noise_array: Array


func _ready() -> void:
	half_chunk = g.half_chunk(chunk_size)
	quarter_chunk = g.quarter_chunk(chunk_size)
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var piles = 0
	var walls = 0
	var drawn = 0
	var noise_val
	var kk
	var vpos
	var margin
	
	# Pass 1 - Draw ground tiles
	margin = 0
	var ground_source_id = 0
	var ground_atlas_size = 8
	var gravel_atlas = Vector2i(ground_atlas_size * 0, 0)
	var ground_atlas = Vector2i(ground_atlas_size * 1, 0)
	var grassd_atlas = Vector2i(ground_atlas_size * 2, 0)
	var grassg_atlas = Vector2i(ground_atlas_size * 3, 0)
	
	for x in range(-half_chunk, half_chunk):
		for y in range(-half_chunk, half_chunk):
			
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			noise_array.append(noise_val)
			vpos = Vector2i(posmod(x, ground_atlas_size),posmod(y, ground_atlas_size))
			
			if noise_val < 0:
				if noise_val < -cente:
					gravel += 1
					# gravel
					ground_tilemap_layer.set_cell(Vector2i(x, y), 
					ground_source_id, gravel_atlas + vpos)
				else:
					ground += 1
					# ground
					ground_tilemap_layer.set_cell(Vector2i(x, y), 
					ground_source_id, ground_atlas + vpos)
			else:
				if noise_val > cente:
					grassg += 1
					# grassg
					ground_tilemap_layer.set_cell(Vector2i(x, y), 
					ground_source_id, grassg_atlas + vpos)
				else:
					grassd += 1
					# grassd
					ground_tilemap_layer.set_cell(Vector2i(x, y), 
					ground_source_id, grassd_atlas + vpos)
			
	# Pass 2 Add piles 
	margin = 1
	var piles_source_id = 1
	var range_from = -quarter_chunk + margin
	var range_to   =  quarter_chunk - margin
	for x in range(range_from, range_to):
		for y in range(range_from, range_to):
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			if posmod(kk,  103) > 101: # 1%
				# check first
				if !static_tilemap_layer.get_cell_tile_data(Vector2i(x, y)):
					piles += 1
					static_tilemap_layer.set_cell(Vector2i(x, y), 
						piles_source_id, Vector2i(0, posmod(kk,  16)))
	
	# Pass 3 Add walls 
	margin = 6
	range_from = -quarter_chunk + margin
	range_to   =  quarter_chunk - margin
	for x in range(range_from, range_to):
		for y in range(range_from, range_to):
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			if posmod(kk, 102) > 100: # 1%
				# Draw lines in 4 directions (SW to N), length from 2 to 7
				var wall_length = posmod(g.get_byte(kk, 3), 5) + 2
				var wall_direction = posmod(g.get_byte(kk, 5), 5)
				walls += 1
				drawn += draw_wall(Vector2i(x, y), wall_direction, wall_length)
	
	# Pass 4 Add Astar
	# Set up parameters, then update the grid.
	astar_grid.region = static_tilemap_layer.get_used_rect()
	astar_grid.cell_size = Vector2(static_tile_size, static_tile_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	# All used cells are obstacles
	# Maybe use get_cell_tile_data(coords: Vector2i) -> get_collision_polygons_count(layer_id: int)
	for tile in static_tilemap_layer.get_used_cells():
		astar_grid.set_point_solid(tile, true)
	# Test Astar
	tilemap_path = astar_grid.get_point_path(Vector2i(0,0), Vector2i(-50, -50))
	tilemap_debug_path.points = tilemap_path

	# Print stats to console
	var s = "gravel : %s\nground : %s\ngrassd : %s\ngrassg : %s" % [gravel, ground, grassg, grassd]
	print("Min : %s" % noise_array.min())
	print("Max : %s" % noise_array.max())
	print("Med : %s" % g.med(noise_array))
	print(s)
	print("+piles : %s" % piles)
	print("+walls : %s" % walls)
	print("+drawn : %s" % drawn)


func draw_wall(global_coords: Vector2i, wall_direction, wall_length) -> int: 
	
	wall_direction = wall_direction % 2 
	# Tileset Source ID
	var wall_source_id = wall_direction + 1
	
	#!!! Starting point in the tilemap
	var tilemap_width: int
	var tilemap_start: Vector2i
	var tilemap_shift: Vector2i
	var tilemap_tiles = []
	var tilemap_tiles_end = []
	var shifted_start: Vector2i

	# Frow NE to SW
	if wall_direction == 0:
		tilemap_width = 3
		tilemap_start = Vector2i(3,0)
		tilemap_shift = Vector2i(-1,1)
		# start tiles (3,0) (3,1) (2,0)
		tilemap_tiles = [Vector2i(0,0), Vector2i(0,1), Vector2i(-1,0)]
		# end tiles (0,2) (0,3) (1,3) (1,2)  
		tilemap_tiles_end = [Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)]
		
	# Frow NW to SE
	if wall_direction == 1:
		tilemap_width = 3
		tilemap_start = Vector2i(0,0)
		tilemap_shift = Vector2i(1,1)
		# start tiles (0,0) (0,1) (1,0)
		tilemap_tiles = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0)]
		# end tiles (2,2) (2,3) (3,2) (3,3)  
		tilemap_tiles_end = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]
		
	# deploy next
	#if wall_direction == 2:
		#shift = Vector2i(-1,-1)
	#if wall_direction == 3:
		#shift = Vector2i(0,-1)
		
	## Start check/set cells
	# check first
	for checked in [false, true]:

		## starting tiles
		for n in tilemap_tiles.size():
			if not checked:
				if static_tilemap_layer.get_cell_tile_data(
					global_coords + tilemap_tiles[n]):
					return 0
			else:
				static_tilemap_layer.set_cell(
					global_coords + tilemap_tiles[n], wall_source_id, 
					tilemap_start + tilemap_tiles[n])

		## repeating in length
		shifted_start = tilemap_start + tilemap_shift
		for i in range(1, wall_length - 1):
			for n in tilemap_tiles.size():
				if not checked:
					if static_tilemap_layer.get_cell_tile_data(
						global_coords + tilemap_tiles[n] + tilemap_shift * i):
						return 0
				else:
					static_tilemap_layer.set_cell(
						global_coords + tilemap_tiles[n] + tilemap_shift * i, wall_source_id, 
						shifted_start + tilemap_tiles[n] + tilemap_shift)
				pass

		## ending tiles
		shifted_start = tilemap_start + tilemap_shift * (tilemap_width - 1) # 0..2
		for n in tilemap_tiles_end.size():
				if not checked:
					if static_tilemap_layer.get_cell_tile_data(
						global_coords + tilemap_tiles_end[n] + tilemap_shift * wall_length):
						return 0
				else:
					static_tilemap_layer.set_cell(
						global_coords + tilemap_tiles_end[n] + tilemap_shift * wall_length, wall_source_id, 
						shifted_start + tilemap_tiles_end[n])
	
	return 1
	
	## @TODO REFACTOR!!! DRY!!!
func find_path(global_position_fron: Vector2, global_position_to:Vector2) -> Array:
	tilemap_path = get_pixel_path(global_position_fron, global_position_to)
	tilemap_debug_path.points = tilemap_path
	return tilemap_path

	## @TODO REFACTOR!!! DRY!!!
func get_pixel_path(from_position, to_position) -> PackedVector2Array:
	var from = static_tilemap_layer.local_to_map(from_position)
	var to = static_tilemap_layer.local_to_map(to_position)
	var pixel_path := astar_grid.get_point_path(from, to)
	return pixel_path
