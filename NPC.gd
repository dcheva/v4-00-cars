extends CharacterBody2D

@onready var g := $loader
@onready var mark := $Mark

# Astar
var generator: Node2D
var tilemap_path := []
@onready var space_state = get_world_2d().direct_space_state

var player : CharacterBody2D

var rot_speed := 0.15
var max_steer := 15.0
var max_speed := 400.0
var speed_change := 0.01
var steer_change := 0.1
var opt_speed := 140.0
var min_speed := 20.0
var breaking := -0.5
var acceleration := 1.2
var track_k_speed := 3.0
var track_k_time := 0.2
var steer := 0.0
var speed := 0.0
var collision_k := 4.0

signal set_hud
signal set_draw_timer

@export var Track_S1_scene: PackedScene
@export var Track_L1_scene: PackedScene

@export var Track_S := preload("res://Track_S1.tscn")
@export var Track_L := preload("res://Track_L1.tscn")

var printed := ""

var pos2:  Vector2
var pos2v: Vector2
var pos2l: float

var timer := 0.0
var wait  := 0.5 # second generator's timeout
var point_range := 200.0 # pixels to target point


func _ready():
	pass


func _physics_process(delta):
	get_input(delta)
	rotation += steer * rot_speed * delta
	velocity = Vector2(0, -speed).rotated(rotation)
	set_velocity(velocity)
	move_and_slide()
	set_hud.emit()


func get_input(delta):
	var speed_to = 0
	var steer_to = steer
	var target_vector
	var target_direction
	
	# Set target to Astar point
	if tilemap_path.size() > 0:
		# Process position
		var next_position = tilemap_path.front()
		if next_position != null:
			mark.global_position = next_position
			pos2  = next_position
			pos2v = global_position - pos2
			pos2l = pos2v.length()
			var p : int = tilemap_path.size()
			var d : int = p * generator.static_tile_size
			printed = "Distance:%s points:%s " % [d, p]
	
	# 1. Timer trigger for generator.find_path 
	if timer > wait:
		tilemap_path = generator.get_apath(global_position, player.global_position)
		timer = 0.0
	else: 
		timer += delta
	
	# 2. Range trigger for target mark distance
	if tilemap_path.size() > 0 and pos2l < (point_range / 2 +  point_range * speed / max_speed):
		tilemap_path.remove_at(0)

	target_direction = to_local(pos2).normalized()
	target_vector = pos2v
	mark.global_position = pos2
	
	# \\ Start AI inputs
	if target_direction.y < 0:
		if target_vector.length() > 100:
			speed_to = max_speed * acceleration
	elif target_direction.y < 0:
			speed_to = max_speed * breaking
	elif target_direction.y > 0:
		if target_vector.length() > 100:
			speed_to = max_speed * acceleration
	if target_direction.x > 0.2:
		steer_to = max_steer
	elif target_direction.x < -0.2:
		steer_to = -max_steer
	
	get_physics(speed_to, steer_to)

func get_drift():
	speed = lerpf(speed, 0.0, speed_change * 4.0)
	steer = steer * steer_change * 4.0

func get_physics(speed_to, steer_to):
	
	# Reverse steering
	if speed < 0: 
		steer_to = -steer_to
		
	# Physics with LERP
	speed = lerpf(speed, speed_to, speed_change)
	steer = lerpf(steer, steer_to, steer_change)

	# Speed steering
	if speed > 0:
		speed = speed - 0.001 * abs(steer) * speed
		if abs(speed) > opt_speed:
			steer = steer * (max_speed - sqrt(abs(speed))) / max_speed
		
	# limits
	steer = clamp(steer, -max_steer, max_steer)
	speed = clamp(speed, -max_speed/2.0, max_speed)

	# Autobrake
	if abs(speed) < min_speed:
		steer = 0
		if speed_to == 0:
			speed = lerpf(speed, 0, speed_change)

	# Collisions
	if get_slide_collision_count() > 0:
		var normal = get_last_slide_collision().get_normal()
		speed = - normal.length() * speed / collision_k
		position = position + normal * collision_k

	# Draw tracks
	if abs(speed) > min_speed:
		set_draw_timer.emit()

func draw_track_timer_formula():
	if sqrt(abs(speed))!=0:
		return track_k_speed / sqrt(abs(speed))
	else:
		return track_k_time

func _on_draw_track_timeout() -> void:
	get_tree().get_root().get_node("Main")._on_draw_track_timeout("Main/NPC")
