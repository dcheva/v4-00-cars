extends Node2D

# @TODO preload settings
@export var chunk_size: int = 512
var half_chunk: int = 256 # chunk_size / 2

@export var noise_height_texture: NoiseTexture2D
var noise: Noise


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
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var piles = 0
	var walls = 0
	var noise_val
	for x in range(-half_chunk, half_chunk):
		for y in range(-half_chunk, half_chunk):
			
			var vpos = Vector2i(posmod(x, atlas_size),posmod(y, atlas_size))
			
			noise_val = noise.get_noise_2d(x, y)
			noise_array.append(noise_val)
			
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
			
			
			# Add statics 
			var kk = noise_val * 9999
			if abs(x * 2) < half_chunk and abs(y * 2) < half_chunk: # 64x64 piles on 32x32 TileMap
				## Add Piles
				if posmod(kk,  102) > 100: # 2%
					piles += 1
					$StaticTileMapLayer.set_cell(Vector2i(x, y), source_id, Vector2i(0, posmod(kk,  16)))
				## Add Walls
				# Must overwrite piles
				elif posmod(kk, 202) > 200: # 1/2%
					# Draw lines in 4 directions (SW to N), length from 3 to 6
					if x > -half_chunk + 6 and y > -half_chunk + 6:
						walls += 1
						var wall_length = posmod(get_byte(kk, 2), 3) + 3
						var wall_direction = posmod(get_byte(kk, 3), 4)
						draw_wall(Vector2i(x, y), wall_direction, wall_length)
			

	var s = "gravel : %s\nground : %s\ngrassd : %s\ngrassg : %s" % [gravel, ground, grassg, grassd]
	print("Min : %s" % noise_array.min())
	print("Max : %s" % noise_array.max())
	print("Med : %s" % med(noise_array))
	print(s)
	print("+piles : %s" % piles)
	print("+walls : %s" % walls)


func draw_wall(coords: Vector2i, wall_direction, wall_length): 
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
	
	# start tiles
	_coords = Vector2i(3,0)
	for n in tiles.size():
		$StaticTileMapLayer.set_cell(coords + tiles[n], _id, _coords + tiles[n])
	
	# repeat in range
	_coords = Vector2i(2,1)
	for i in range(1, wall_length - 1):
		for n in tiles.size():
			$StaticTileMapLayer.set_cell(coords + tiles[n] + shift * i, _id, _coords + tiles[n] + shift)
	
	# end tiles
	_coords = Vector2i(0,3)
	for n in tiles_end.size():
		$StaticTileMapLayer.set_cell(coords + tiles_end[n] + shift * wall_length, _id, _coords + tiles_end[n])
	
	

# Math
func get_byte(num: int, pos: int):
	for i in range (1, pos):
		num = num % 10
	return posmod(num, 10)	

func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result
	
func med(arr:Array):
	return sum(arr)/arr.size()
