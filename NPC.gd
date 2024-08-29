extends CharacterBody2D

@onready var g = $loader

# Astar
var tilemap_path := []

var player : CharacterBody2D

var rot_speed := 0.15
var max_steer := 15
var max_speed := 400
var speed_change := 0.01
var steer_change := 0.1
var opt_speed := 140
var min_speed := 20
var breaking := -0.5
var acceleration := 1.2
var track_k_speed := 3.0
var track_k_time := 0.2
var ray_length := 1000
var ray_avoid := 250
var steer := 0.0
var speed := 0.0
var collision_k := 4.0

signal set_hud
signal set_draw_timer

@export var Track_S1_scene: PackedScene
@export var Track_L1_scene: PackedScene

@export var Track_S := preload("res://Track_S1.tscn")
@export var Track_L := preload("res://Track_L1.tscn")

var text := ""
var printed := ""
var printed_distance := ""
var target_vector_length
var player_last_seen
var player_global_transform


func _ready():
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
	var steer_to = steer
	var target_vector
	var target_direction
	var t = ""

	var target_global_position = player.global_position
	# Set target to Astar point
	for next_position in tilemap_path:
		# raycast to position and find farest
		pass
		
	target_direction = to_local(player.global_transform.origin).normalized()
	target_vector = Vector2(global_position - target_global_position)
	target_direction = target_direction #direction to player
	target_vector_length = int(target_vector.length())
	
	# \\ Start AI inputs
	if target_direction.y < 0:
		t += "ahead, "
		if target_vector.length() > 200:
			speed_to = max_speed * acceleration
		elif target_vector.length() < 100:
			get_drift()
	elif target_direction.y < 0:
			speed_to = max_speed * breaking
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
	
	printed_distance = "NPC to Player: " + t.trim_suffix(", ")
	get_physics(speed_to, steer_to)


func get_drift():
	speed = lerpf(speed, 0.0, speed_change * 4.0)
	steer = steer * steer_change * 4.0


func get_physics(speed_to, steer_to):
	
	# Reverse steering
	if speed < 0: 
		steer_to = -steer_to

	# Physics with LERP
	speed = lerpf(speed, 
	speed_to, 
	speed_change)
	steer = lerpf(steer, steer_to, steer_change)

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
			speed = lerpf(speed, 0, speed_change)
	
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
		return track_k_time


func _on_draw_track_timeout() -> void:
	get_tree().get_root().get_node("Main")._on_draw_track_timeout("Main/NPC")
	

## @DEPRECATED 
## old stuff from raycast branch
func get_rays():
	## old globals
	var avoid := {fwd = 999, left = 999, right = 999}
	var player_invisible := false
	# tutorials/physics/ray-casting.html#raycast-query
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var ray_from = global_transform.origin
	var trace_to: Vector2
	var query: PhysicsRayQueryParameters2D
	var result: Dictionary
	# trace rays
	var rays_rotated = [-PI, 0, -PI/9, -PI/7, -PI/5, PI/9, PI/7, PI/5] 
	printed = ""
	for i in rays_rotated:
		if i == -PI:
			trace_to = player.global_position
		else: 
			trace_to = ray_from + velocity.normalized() * ray_length
			trace_to = trace_to.rotated(i)
		query = PhysicsRayQueryParameters2D.create(ray_from, trace_to)
		# tutorials/physics/ray-casting.html#collision-exceptions
		query.exclude = [self]
		result = space_state.intersect_ray(query)
		if result:
			var pos2i = result.get("position")
			var pos2v = global_position - pos2i
			var pos2l = int(pos2v.length())
			var col_obj = result.get("collider")
			if i <= -PI/9:
				text = "<<-"
				if col_obj != player:
					avoid.left = min(avoid.left, pos2l)
			if i >= PI/9:
				text = "->>"
				if col_obj != player:
					avoid.right = min(avoid.right, pos2l)
			if i == 0    : 
				text = "^|^"
				if col_obj != player:
					avoid.fwd = pos2l
			#printed += "Ray hits %s: %s\n->%s\n[!]: %s\n" % [text,Vector2i(pos2i),col_obj,avoid]
			# Remember player las seen
			if i == -PI:
				if col_obj == player:
					player_invisible = false
					$Mark.hide()
					player_last_seen = player.global_position
					$Mark.global_position = player_last_seen
					player_global_transform = player.global_transform
				else:
					player_invisible = true
					$Mark.show()
