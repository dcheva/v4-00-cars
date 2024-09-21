extends Node2D

@onready var g = $loader

# Astar grid
@onready var astar_grid = AStarGrid2D.new()
@onready var ground_tilemap_layer: TileMapLayer = $GroundTileMapLayer
@onready var static_tilemap_layer: TileMapLayer = $StaticTileMapLayer
@onready var tilemap_debug_path: Line2D = $DebugLine2D
var static_tile_size: Vector2
var tilemap_path: Array

@export var chunk_size: int = 256
var half_chunk: int
var quarter_chunk: int
var eighth_chunk: int

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var wall_max_length = 4
var cente: float = 0.25
var gravel: int
var ground: int
var grassg: int
var grassd: int
var noise_val

var directions := [
	Vector2.UP + Vector2.LEFT,
	Vector2.UP + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.DOWN + Vector2.RIGHT,
	]
var farts_burning_area: Vector2
var farts_liveing_area: Vector2
var farts_droping_area: Vector2

func _ready() -> void:
	half_chunk = g.half_chunk(chunk_size)
	quarter_chunk = g.quarter_chunk(chunk_size)
	eighth_chunk = g.eighth_chunk(chunk_size)
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:	
	print("Generator started")
	print("1 Draw ground tiles:")
	draw_ground_tiles()
	print("2 Draw piles:")
	var piles := draw_piles()
	print("3 Draw walls:")
	var walls = draw_walls()
	print("4 Set Astar:")
	set_astar()
	print("5 Set zones:")
	set_zones()

	# Print stats to console
	var arr := [gravel, ground, grassg, grassd] 
	print("gravel : %s\nground : %s\ngrassd : %s\ngrassg : %s" % arr)
	print("+piles : %s" % piles)
	print("+walls : %s" % walls)

func draw_ground_tiles() -> void:
	var ground_source_id = 0
	var ground_atlas_size = 8
	var gravel_atlas = Vector2i(ground_atlas_size * 0, 0)
	var ground_atlas = Vector2i(ground_atlas_size * 1, 0)
	var grassd_atlas = Vector2i(ground_atlas_size * 2, 0)
	var grassg_atlas = Vector2i(ground_atlas_size * 3, 0)
	
	for x in range(-half_chunk, half_chunk):
		for y in range(-half_chunk, half_chunk):
			
			noise_val = noise.get_noise_2d(x, y)
			var vpos = Vector2i(posmod(x, ground_atlas_size),posmod(y, ground_atlas_size))
			
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
					
func draw_piles() -> int:
	# 2 Add piles 
	var piles := 0 
	var margin = 1
	var piles_source_id = 0
	var range_from = -quarter_chunk + margin
	var range_to   =  quarter_chunk - margin
	for x in range(range_from, range_to):
		for y in range(range_from, range_to):
			noise_val = noise.get_noise_2d(x, y)
			var kk = noise_val * 999999
			if posmod(kk,  103) > 101: # 2%
				# check first
				if !static_tilemap_layer.get_cell_tile_data(Vector2i(x, y)):
					piles += 1
					static_tilemap_layer.set_cell(Vector2i(x, y), 
						piles_source_id, Vector2i(0, posmod(kk,  16)))
	return piles

func draw_walls() -> int:
	var margin = 6
	var walls := 0
	var range_from = -quarter_chunk + margin
	var range_to   =  quarter_chunk - margin
	for x in range(range_from, range_to):
		for y in range(range_from, range_to):
			noise_val = noise.get_noise_2d(x, y)
			var kk = noise_val * 999999
			if posmod(kk, 202) > 200: # x%
				# Draw lines in 4 directions (SW to N), length from 2 to 7
				var five = g.get_byte(kk, 5)
				var wall_length = posmod(five, 3) + 2
				var wall_direction = posmod(g.get_byte(five, 5), 5)
				walls += draw_wall(Vector2i(x, y), wall_direction, wall_length)
	return walls

func draw_wall(global_coords: Vector2i, wall_direction, wall_length) -> int: 
	# Tileset Source ID (index 0 are piles)
	var wall_source_id = wall_direction + 1
	
	#!!! Starting point in the tilemap
	var tilemap_start: Vector2i
	var tilemap_shift: Vector2i
	var tilemap_tiles = []
	var tilemap_tiles_end = []

	# Frow NE to SW
	if wall_direction == 0:
		wall_length = clamp(wall_length, 2, wall_max_length)
		tilemap_start = Vector2i(0,3)
		# start tiles (2,0) (3,0) (3,1)
		tilemap_tiles = [Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0)]
		# target tiles (1,1) (2,1) (2,2)
		tilemap_shift = Vector2i(1,-1)
		# end tiles (0,2) (1,2) (1,3) (0,3)  
		tilemap_tiles_end = [Vector2i(1,1), Vector2i(1,2), Vector2i(2,2), Vector2i(2,1)]
		
	# Frow NW to SE
	if wall_direction == 1:
		wall_length = clamp(wall_length, 2, wall_max_length)
		tilemap_start = Vector2i(0,0)
		# start tiles (0,1) (0,0) (1,0)
		tilemap_tiles = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0)]
		# target tiles (1,2) (1,1) (2,1)
		tilemap_shift = Vector2i(1,1)
		# end tiles (2,2) (2,3) (3,2) (3,3)  
		tilemap_tiles_end = [Vector2i(1,1), Vector2i(1,2), Vector2i(2,1), Vector2i(2,2)]
		
	# Horizontal
	if wall_direction == 2:
		# Tiles are doublesized
		wall_length = clamp(wall_length/2, 2, wall_max_length)
		tilemap_start = Vector2i(5,0)
		tilemap_tiles = [Vector2i(0,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(-1,1)]
		tilemap_shift = Vector2i(-2,0)
		tilemap_tiles_end = [Vector2i(2,0), Vector2i(2,1), Vector2i(3,0), Vector2i(3,1)]
		
	# Vertical
	if wall_direction == 3:
		# Tiles are doublesized
		wall_length = clamp(wall_length/2 + 1, 2, wall_max_length)
		tilemap_start = Vector2i(0,5)
		tilemap_tiles = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(1,-1)]
		tilemap_shift = Vector2i(0,-2)
		tilemap_tiles_end = [Vector2i(0,2), Vector2i(1,2), Vector2i(0,3), Vector2i(1,3)]
		
	## Start check/set cells
	for checked in [false, true]:
		### starting tiles
		for n in tilemap_tiles.size():
			var static_tilemap_coords = Vector2i(
					global_coords + tilemap_tiles[n])
			# check first
			if not checked:
				if static_tilemap_layer.get_used_cells().has(static_tilemap_coords):
						return 0
			else:
				static_tilemap_layer.set_cell(
					static_tilemap_coords, 
					wall_source_id, 
					tilemap_start + tilemap_tiles[n])
				pass

		## repeating in length
		for i in range(1, wall_length - 1):
			for n in tilemap_tiles.size():
				var static_tilemap_coords = Vector2i(
						global_coords + tilemap_tiles[n] + tilemap_shift * i)
				# check first
				if not checked:
					if static_tilemap_layer.get_used_cells().has(static_tilemap_coords):
							return 0
				else:
					static_tilemap_layer.set_cell(
						static_tilemap_coords, 
						wall_source_id, 
						tilemap_start + tilemap_shift + tilemap_tiles[n])

		## ending tiles
		for n in tilemap_tiles_end.size():
			var static_tilemap_coords = Vector2i(
					global_coords - tilemap_start 
					+ tilemap_shift * (wall_length-2) + tilemap_tiles_end[n])
			# check first
			if not checked:
				if static_tilemap_layer.get_used_cells().has(static_tilemap_coords):
					return 0
			else:
				static_tilemap_layer.set_cell(
					static_tilemap_coords, 
					wall_source_id, 
					tilemap_tiles_end[n] + tilemap_shift)
	# Finished: +1
	return 1

func set_astar() -> void:
	# Set up parameters, then update the grid.
	astar_grid.region = static_tilemap_layer.get_used_rect()
	astar_grid.cell_size = static_tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	# All used cells are obstacles
	# Maybe use get_cell_tile_data(coords: Vector2i) -> get_collision_polygons_count(layer_id: int)
	for tile in static_tilemap_layer.get_used_cells():
		astar_grid.set_point_solid(tile, true)
	# Test Astar
	tilemap_path = astar_grid.get_point_path(Vector2i(0,0), Vector2i(-50, -50))
	tilemap_debug_path.points = tilemap_path
	

func set_zones() -> void:
	## Create 4 zones: Farts-burning, Fart-targeting, Drop-off and Starting
	## 1. Farts-burning
	var dir_burn = g.rarr(directions)
	print("farts_burning_area: ", dir_burn)
	farts_burning_area = Vector2(quarter_chunk, quarter_chunk) * dir_burn
	var dir_live = g.rarr(directions)
	print("farts_living_area: ", dir_live)
	farts_liveing_area = Vector2(quarter_chunk, quarter_chunk) * dir_live
	var dir_drop = g.rarr(directions)
	print("farts_droping_area: ", dir_drop)
	farts_droping_area = Vector2(quarter_chunk, quarter_chunk) * dir_drop
	
	
	
func get_apath(from_position, to_position) -> PackedVector2Array:
	var from = static_tilemap_layer.local_to_map(from_position)
	var to = static_tilemap_layer.local_to_map(to_position)
	tilemap_path = astar_grid.get_point_path(from, to)
	return tilemap_path
