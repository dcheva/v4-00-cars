extends Node2D

var g

@export var chunk_size: int = 512
var half_chunk: int
var quarter_chunk: int

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

# Astar grid
var astar_grid = AStarGrid2D.new()
var path = []

var gravel: int
var ground: int
var grassg: int
var grassd: int
var cente: float = 0.25
var noise_array: Array

var source_id = 0
var atlas_size = 8
var gravel_atlas = Vector2i(atlas_size * 0, 0)
var ground_atlas = Vector2i(atlas_size * 1, 0)
var grassd_atlas = Vector2i(atlas_size * 2, 0)
var grassg_atlas = Vector2i(atlas_size * 3, 0)

func _ready() -> void:
	g = $loader
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
	for x in range(-half_chunk, half_chunk):
		for y in range(-half_chunk, half_chunk):
			
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			noise_array.append(noise_val)
			vpos = Vector2i(posmod(x, atlas_size),posmod(y, atlas_size))
			
			if noise_val < 0:
				if noise_val < -cente:
					gravel += 1
					# gravel
					$TileMapLayer.set_cell(Vector2i(x, y), source_id, gravel_atlas + vpos)
				else:
					ground += 1
					# ground
					$TileMapLayer.set_cell(Vector2i(x, y), source_id, ground_atlas + vpos)
			else:
				if noise_val > cente:
					grassg += 1
					# grassg
					$TileMapLayer.set_cell(Vector2i(x, y), source_id, grassg_atlas + vpos)
				else:
					grassd += 1
					# grassd
					$TileMapLayer.set_cell(Vector2i(x, y), source_id, grassd_atlas + vpos)
			
	# Pass 2 Add piles 
	margin = 1
	for x in range(-quarter_chunk + margin, quarter_chunk - margin):
		for y in range(-quarter_chunk + margin, quarter_chunk - margin):
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			if posmod(kk,  103) > 101: # 1%
				piles += 1
				$StaticTileMapLayer.set_cell(Vector2i(x, y), source_id, Vector2i(0, posmod(kk,  16)))
	
	# Pass 3 Add walls 
	margin = 6
	for x in range(-quarter_chunk + margin, quarter_chunk - margin):
		for y in range(-quarter_chunk + margin, quarter_chunk - margin):
			noise_val = noise.get_noise_2d(x, y)
			kk = noise_val * 999999
			if posmod(kk, 102) > 100: # 1%
				# Draw lines in 4 directions (SW to N), length from 2 to 7
				var wall_length = posmod(g.get_byte(kk, 3), 5) + 2
				var wall_direction = posmod(g.get_byte(kk, 4), 4)
				walls += 1
				drawn += draw_wall(Vector2i(x, y), wall_direction, wall_length)
				
	# Pass 4 Add Astar
	# Set up parameters, then update the grid.
	var tilemap_layer = $StaticTileMapLayer
	astar_grid.region = tilemap_layer.get_used_rect()
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	# Print stats to console
	var s = "gravel : %s\nground : %s\ngrassd : %s\ngrassg : %s" % [gravel, ground, grassg, grassd]
	print("Min : %s" % noise_array.min())
	print("Max : %s" % noise_array.max())
	print("Med : %s" % $loader.med(noise_array))
	print(s)
	print("+piles : %s" % piles)
	print("+walls : %s" % walls)
	print("+drawn : %s" % drawn)


func draw_wall(coords: Vector2i, wall_direction, wall_length) -> int: 
	wall_direction = 0
	var _id = wall_direction + 1
	var shift: Vector2i
	var _coords: Vector2i
	var tiles = []
	var tiles_end = []

	if wall_direction == 0:
		shift = Vector2i(-1,1)
		# start tiles (3,0) (3,1) (2,0)
		tiles = [Vector2i(0,0), Vector2i(0,1), Vector2i(-1,0)]
		# end tiles (0,2) (0,3) (1,3) (1,2)  
		tiles_end = [Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)]
	if wall_direction == 1:
		shift = Vector2i(-1,0)
	if wall_direction == 2:
		shift = Vector2i(-1,-1)
	if wall_direction == 3:
		shift = Vector2i(0,-1)
		
	# check first
	for checked in [false, true]:
		# start tiles
		_coords = Vector2i(3,0)
		for n in tiles.size():
			if not checked:
				if $StaticTileMapLayer.get_cell_tile_data(coords + tiles[n]):
					return 0
			else:
				$StaticTileMapLayer.set_cell(coords + tiles[n], _id, _coords + tiles[n])
		
		# repeat in length
		_coords = Vector2i(2,1)
		for i in range(1, wall_length - 1):
			for n in tiles.size():
				if not checked:
					if $StaticTileMapLayer.get_cell_tile_data(coords + tiles[n] + shift * i):
						return 0
				else:
					$StaticTileMapLayer.set_cell(coords + tiles[n] + shift * i, _id, _coords + tiles[n] + shift)
		
		# end tiles
		_coords = Vector2i(0,3)
		for n in tiles_end.size():
				if not checked:
					if $StaticTileMapLayer.get_cell_tile_data(coords + tiles_end[n] + shift * wall_length):
						return 0
				else:
					$StaticTileMapLayer.set_cell(coords + tiles_end[n] + shift * wall_length, _id, _coords + tiles_end[n])
	
	return 1
	
	
