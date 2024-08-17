extends Node2D

@export var noise_height_texture: NoiseTexture2D

var noise: Noise

var width:  int = 512
var height: int = 512

var gravel: int
var ground: int
var grassg: int
var grassd: int
var cente: float = 0.25
var noise_array: Array

var source_id = 0
var gravel_atlas = Vector2i( 0, 0)
var ground_atlas = Vector2i( 4, 0)
var grassd_atlas = Vector2i( 8, 1)
var grassg_atlas = Vector2i(12, 1)

func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var noise_val
	for x in range(width):
		for y in range(height):
			noise_val = noise.get_noise_2d(x,y)
			noise_array.append(noise_val)
			if noise_val < 0:
				if noise_val < -cente:
					gravel += 1
					# gravel
				else:
					ground += 1
					# ground
			else:
				if noise_val > cente:
					grassg += 1
					# grassg
				else:
					grassd += 1
					# grassd
		
	var s = "gravel : %s\nground : %s\ngrassd : %s\ngrassg : %s\n" % [gravel, ground, grassg, grassd]
	print("Min: %s" % noise_array.min())
	print("Max: %s" % noise_array.max())
	print("Med: %s" % med(noise_array))
	print(s)

# Math
func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result
	
func med(arr:Array):
	return sum(arr)/arr.size()
