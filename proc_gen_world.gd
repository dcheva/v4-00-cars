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

func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var noise_val
	for x in range(width):
		for y in range(height):
			noise_val = noise.get_noise_2d(x,y)
			noise_array.append(noise_val)
			if noise_val > cente:
				mores += 1
			elif noise_val < -cente:
				leses += 1
			else:
				zeros += 1
		
	var str = "-cente : %s\n cente : %s\n+cente : %s\n" % [leses, mores, zeros]
	print("Min: %s" % noise_array.min())
	print("Max: %s" % noise_array.max())
	print("Med: %s" % med(noise_array))
	print(str)

# Math
func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result
	
func med(arr:Array):
	return sum(arr)/arr.size()
