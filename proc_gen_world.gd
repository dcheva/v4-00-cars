extends Node2D

@export var noise_height_texture: NoiseTexture2D

var noise: Noise

var width:  int = 512
var height: int = 512

var mores: int
var leses: int
var zeros: int
var cente: float = 0.333
var noise_array: Array

var source_id = 0
var gravel_atlas = Vector2i(0, 1)
var bushes_atlas = Vector2i(0, 1)
var ground_atlas = Vector2i(0, 1)

func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var noise_val
	for x in range(width):
		for y in range(height):
			noise_val = noise.get_noise_2d(x,y)
			noise_array.append(noise_val)
			if noise_val < -cente:
				leses += 1
				# gravel
			elif noise_val > cente:
				mores += 1
				# bushes
			else:
				zeros += 1
				# ground
		
	var s = "-cente(gravel) : %s\n cente(ground) : %s\n+cente(bushes) : %s\n" % [leses, zeros, mores]
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
