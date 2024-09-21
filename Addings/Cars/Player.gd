extends CharacterBody2D

# @TODO preload settings
@export var rot_speed = 0.15
@export var speed_change = 0.01
@export var steer_change = 0.1
@export var max_steer = 15
@export var max_speed_shift = 600
@export var max_speed_drive = 300
@export var opt_speed = 100
@export var min_speed = 20
@export var breaking = -0.5
@export var acceleration = 1.2
@export var sound_pitch_min := 0.5
@export var sound_pitch_max := 1.0
@export var collision_k = 4
@export var track_k_speed = 3
@export var track_k_time = 0.2
var max_speed = 0
var steer = 0
var speed = 0

signal set_hud
signal set_draw_timer

var Track_S_scene: PackedScene
var Track_L_scene: PackedScene

var Track_S = preload("res://Addings/Cars/Parts/Track_S.tscn")
var Track_L = preload("res://Addings/Cars/Parts/Track_L.tscn")

@onready var animation_player = $AnimationPlayer
@onready var state_machine := $FiniteStateMachine


func _ready():
	state_machine.start()
	pass
	

func _physics_process(delta):
	get_input()
	rotation += steer * rot_speed * delta
	velocity = Vector2(0, -speed).rotated(rotation)
	set_velocity(velocity)
	move_and_slide()
	set_hud.emit()


func get_input():
	var speed_to = 0
	var steer_to = 0
	
	if Input.is_action_pressed("shift"):
		max_speed = lerpf(max_speed, max_speed_shift, speed_change * 4)
	else: 
		max_speed = lerpf(max_speed, max_speed_drive, speed_change * 4)
	if Input.is_action_pressed("up_arrow"):
		speed_to = max_speed * acceleration
	if Input.is_action_pressed("down_arrow"):
		speed_to = max_speed * breaking
	if Input.is_action_pressed("right_arrow"):
		steer_to = max_steer
	if Input.is_action_pressed("left_arrow"):
		steer_to = -max_steer
	if Input.is_action_pressed("space"):
		get_drift()
	get_physics(speed_to, steer_to)


func get_drift():
	speed = lerpf(speed, 0, speed_change * 4)
	steer = steer * steer_change * 16


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
	if abs(speed) < opt_speed or speed < 0:
		if !Input.is_action_pressed("space"):
			steer = steer * (abs(speed) + min_speed) / opt_speed
		
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
		
	pitch_player_engine_bus()


func pitch_player_engine_bus() -> void:
	# Play right sound !!!IMPORTANT!!!
	var sound_pitch: float = clamp(
		abs(speed) / max_speed, 
		sound_pitch_min, 
		sound_pitch_max
		)
	var as_id := AudioServer.get_bus_index("PlayerEngine")
	var as_ef := AudioServer.get_bus_effect(as_id, 0)
	as_ef.pitch_scale = sound_pitch


func draw_track_timer_formula():
	if sqrt(abs(speed))!=0:
		return track_k_speed / sqrt(abs(speed))
	else:
		return track_k_time


func _on_draw_track_timeout() -> void:
	get_parent()._on_draw_track_timeout("Player")
