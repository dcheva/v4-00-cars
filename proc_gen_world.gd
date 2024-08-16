extends Node2D

@export var noise_height_texture: NoiseTexture2D

var noise: Noise

var width:  int = 100
var height: int = 100

func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world() -> void:
	var noise_val
	for x in range(width):
		for y in range(height):
			noise_val = noise.get_noise_2d(x,y)
	prints(noise_val)
