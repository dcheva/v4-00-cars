extends CharacterBody2D

# @TODO preload settings
@export var rot_speed = 0.15
@export var max_steer = 15
@export var max_speed = 400
@export var opt_speed = 140
@export var min_speed = 20
@export var breaking = -0.5
@export var acceleration = 1.2
@export var collision_k = 4
@export var track_l_speed = 145
@export var track_k_speed = 3
var steer = 0
var speed = 0

signal set_hud
signal set_draw_timer

@export var Track_S1_scene: PackedScene
@export var Track_L1_scene: PackedScene

@export var Track_S = preload("res://Track_S1.tscn")
@export var Track_L = preload("res://Track_L1.tscn")

var printed = ""
var target_vector_length = 0

func _ready():
	pass


func _physics_process(delta):
	get_input()
	rotation += steer * rot_speed * delta
	velocity = Vector2(0, -speed).rotated(rotation)
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	set_hud.emit()


func get_input():
	var speed_to = 0
	var steer_to = steer

	var player = get_tree().get_root().get_node("Main/Player")
	var target_vector = Vector2(position - player.position)
	target_vector_length = int(target_vector.length()/10)
	var target_direction = to_local(player.global_transform.origin).normalized() #direction to player

	# \\ Start AI inputs
	var t = "%s m. " % target_vector_length
	if target_direction.y < 0:
		t += "ahead, "
		if target_vector.length() > 200:
			speed_to = max_speed * acceleration
		elif target_vector.length() < 100:
			get_drift()
	elif target_direction.y > 0:
		t += "behind, "
		if target_vector.length() > 400:
			speed_to = max_speed * acceleration
		elif target_vector.length() > 200:
			speed_to = max_speed * breaking
		elif target_vector.length() < 100:
			get_drift()
	if target_direction.x > 0.1:
		t += "in the right, " 
		steer_to = max_steer
	elif target_direction.x < -0.1:
		t += "in the left, "
		steer_to = -max_steer
	# // End AI inputs
	t = t.trim_suffix(", ")
	if printed != t:
		printed = t
		
	get_physics(speed_to, steer_to)


func get_drift():
	speed = lerpf(speed, 0, 0.1)
	steer = steer * 2


func get_physics(speed_to, steer_to):
	
	# Reverse steering
	if speed < 0: 
		steer_to = -steer_to

	# Physics with LERP
	speed = lerpf(speed, speed_to, 0.01)
	steer = lerpf(steer, steer_to, 0.1)

	# Speed ​​steering
	if speed > 0:
		speed = speed - 0.001 * abs(steer) * speed
		if abs(speed) < opt_speed:
			steer = steer * ((abs(speed) + opt_speed) / (2 * opt_speed))
		if abs(speed) > opt_speed:
			steer = steer * (max_speed - sqrt(abs(speed))) / max_speed

	# Speed limits
	steer = clamp(steer, -max_steer, max_steer)
	speed = clamp(speed, -max_speed/2.0, max_speed)

	# Autobrake
	if abs(speed) < min_speed:
		steer = 0
		if speed_to == 0:
			speed = lerpf(speed, 0, 0.1)
	
	# Collisions
	if get_slide_collision_count() > 0:
		var normal = get_last_slide_collision().get_normal()
		speed = - normal.length() * speed / collision_k
		position = position + normal * collision_k
	
	if abs(speed) > min_speed:
		set_draw_timer.emit()


func draw_track_timer_formula():
	if sqrt(abs(speed))!=0:
		return track_k_speed / sqrt(abs(speed))
	else:
		return 0.2


func _on_draw_track_timeout() -> void:
	get_tree().get_root().get_node("Main")._on_draw_track_timeout("Main/NPC")
