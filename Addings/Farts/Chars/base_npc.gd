extends CharacterBody2D


@export var dexta := 5.0
@export var speed := 200.0 * 50 /Engine.physics_ticks_per_second
@export var shift := 400.0 * 50 /Engine.physics_ticks_per_second
@export var lead_vector := Vector3.ZERO
@export var global_target := Vector2.ZERO
@export var state : StringName


var leader := false


var tile_size: Vector2
var camera: Camera2D
var func_get_astar_path: Callable
var func_get_free_static_cells: Callable
var astar_array: Array
var timer: float = 0.0
var global_center : Vector2
var target : Vector2
var target_obj: Node
var state_machine : FiniteStateMachine
var animations : AnimationPlayer
var particles : CPUParticles2D
var sounds : AudioStreamPlayer2D
var abes : Array
var color : Color:
	set(val):
		paint_color(self, val)
		color = val


func _init() -> void:
	print(name, " ready: ", set_color(pick_random_color()))
	## Append attachable
	abes.append(attachable("Diffuse"))


func _physics_process(delta: float) -> void:
	## Move
	velocity = lerp(velocity, get_input(delta) * speed, delta * dexta)
	## Stop
	if velocity.length() < speed / dexta and astar_array.size() < 1:
		velocity = Vector2.ZERO
	move_and_slide()
	
	
func set_color(mod_color: Color) -> Color:
	## Use one base color and add random Vector3 RGB
	var base_colors := [
		#Color.CYAN, 
		#Color.MAGENTA, 
		#Color.YELLOW,
		Color.RED, 
		Color.GREEN, 
		Color.BLUE
		]
	color = normalize_color(mod_color + base_colors.pick_random())
	return color


func pick_random_color() -> Color:
	var rv = Vector3(randf(),randf(),randf()).normalized()
	return Color(rv.x, rv.y, rv.z)


func get_input(delta) -> Vector2:
	timer += delta
	## Get target and direction
	var velocity_to: Vector2 = global_position.direction_to(
		get_current_target()).normalized()
	
	# Speed shift
	if astar_array.size() > 1 and !leader:
		velocity_to *= shift / speed
	
	# Collisions !!!HERE because FSM cant process slide_collisions
	if get_slide_collision_count() > 0:
		var normal = get_last_slide_collision().get_normal()
		position +=  normal * dexta + Vector2(
			randi_range(-8,8),randi_range(-8,8))
		velocity = Vector2.ZERO
		if not leader: reset_to_idle()
		
	return velocity_to


func get_current_target():
	## Get target via get_current_star
	if astar_array.size() > 0:
		target = get_current_star()
		$Cross.global_position = target
	return target
	

func get_current_star() -> Vector2:
	## Get current star from Astar array
	var star: Vector2 = astar_array.front()
	if (star - self.global_position).length() < Vector2(tile_size / 2).length():
		astar_array.remove_at(0)
	return star


func set_current_target(new_target: Vector2) -> bool:
	target = new_target
	astar_array = get_static_astar(target)
	return astar_array.size() > 0
	
func set_global_target(new_target: Vector2) -> bool:
	if new_target != Vector2.ZERO:
		global_target = new_target
		target = new_target
		astar_array = get_static_astar(new_target)
		return astar_array.size() > 0
	else: 
		global_target = global_position
		target = global_position
		return false
	

func update_current_target() -> bool:
	if target_obj is CharacterBody2D:
		target = target_obj.global_position
	else:
		return false
	astar_array = get_static_astar(target)
	if astar_array.size() <= 2:
		var t: StringName
		if target_obj.leader:
			t = "Leader: "
		else:
			t = "Target: "
		t += target_obj.name
		print(name, " Reached ", t, " in time: ",
		"now" if int(timer) == 0 else "%s" % int(timer))
		target_obj = null
		reset_to_state("Success")
		return false
	else:
		return true
	
	
func get_random_position() -> Vector2:
	randomize()
	var free_cells: Array[Vector2] = func_get_free_static_cells.call()
	var rand_pos = free_cells.pick_random()
	return global_center + rand_pos * tile_size + tile_size / 2


func set_random_position() -> void:
	self.global_position = self.get_random_position()


func get_static_astar(targeted: Vector2) -> Array:
	## Get Astar Statics navigation array from Current position to Target position
	var targeted_astar_array = func_get_astar_path.call(
		self.global_position, targeted)
	return targeted_astar_array


## Reset to minimal timer as default
func reset_to_idle(from_timer: float = 3.0) -> void:
	timer = from_timer
	target = global_position
	astar_array = []
	reset_to_state("Initial")
	
	
func reset_to_target(target_body: CharacterBody2D) -> void:
	target = target_body.global_position
	target_obj = target_body
	reset_to_state("Target")
	
	
func reset_to_state(fsm_state: StringName) -> void:
	animations.play("RESET")
	state = fsm_state
	state_machine.change_state(get_fsm_state(fsm_state))
	
	
func get_fsm_state(state_name: StringName) -> FSMState:
	for found_state in state_machine.states:
		if found_state.name == state_name:
			return(found_state)
	## if not found return initial as defined
	return state_machine.initial_state


func _on_sens_body_entered(body: Node2D) -> void:
	## @TODO need BT here:
	## - if not Leader: hear to someone Speaking
	## - else do something with someone's entered the sens area
	if (not leader
	and body.is_in_group("NPC") 
	and body.animations.is_playing() 
	and body.animations.current_animation == "Speak"):
		print(name, " is hearing ", body.name, " speak ", body.color)

		var color_vector = diffuse_rand_color(self, body.color).normalized()
		var color_amount = int(color_vector.length() * 5 + 5)

		body.lead_vector += color_vector * 2
		var resize: float = body.lead_vector.length()
		print(body.name, " lead_vector is ", body.lead_vector, 
		" (%s) !!!" % resize)
		
		## Confirm or dismiss the Leader
		if resize > 20:
			dismiss_leader(body)
			print (body.name, " DISMISSED!!!")
		elif resize > 10:
			if confirm_leader(body):
				print (body.name, " CONFIRMED!!!")
		elif resize > 1:
			body.scale = Vector2(1 + resize/20.0, 1 + resize/20.0)
		## Call attachable.execute()
		var args: Dictionary
		args.from = body
		args.to = self
		args.color = Color(color_vector.x, color_vector.y, color_vector.z)
		if args.color == Color.BLACK:
			## Fix the BLACK!
			args.color = Color.SLATE_GRAY
		args.amount = color_amount
		var res = abes[0].execute(args)
		## Print the answer result
		if res != {}:
			print(res)


func confirm_leader(body: CharacterBody2D) -> bool:
	if body.leader:
		print(body.name, " NOT CONFIRMED!!! Already is the Leader")
		return false
	if find_leaders() > 0:
		print(body.name, " NOT CONFIRMED!!! Already has the Leader")
		return false
	body.scale = Vector2(2,2)
	
	print_debug (body, true)
	set_as_leader(body, true)
	return body.leader


func dismiss_leader(body: CharacterBody2D) -> void:
	body.lead_vector = Vector3.ZERO
	body.color = Color.LIGHT_SLATE_GRAY
	body.scale = Vector2(1,1)
	
	print_debug (body, false)
	set_as_leader(body, false)
	pass


func set_as_leader(body: CharacterBody2D, val: bool) -> void:
	body.leader = val
	body.find_child("Leader").visible = val
	body.set_collision_layer_value(1, !val)
	body.set_collision_mask_value(1, !val)
	pass
	
	
func find_leaders() -> int:
	var leaders_count := 0
	for child in get_parent().get_children():
		## Check is it new NPC
		if child.is_in_group("NPC") and child.leader == true:
			leaders_count += 1
	return leaders_count

	
func attachable(abe_name: StringName, args: Array = []) -> Node:
	## Instantiate ability
	var fname := "res://Addings/Abes/Abilities/" + abe_name + "/" + abe_name
	var scene = load(fname + ".tscn")
	var script = load(fname + ".gd")
	var instance: Node2D = scene.instantiate()
	add_child(instance)
	## Setting up an instance and script
	instance.set_script(script)
	## Force calling _process()
	instance.set_process(true)
	print("Node \"", name, "\" attached ", abe_name, args)
	return instance


func diffuse_rand_color(body:CharacterBody2D, add_color:Color) -> Vector3:
	## Iterate colors and randomly clear RGB
	var add_color_arr = [add_color.r, add_color.g, add_color.b]
	var add_base_arr  = ["r", "g", "b"]
	for c in add_base_arr:
		var i := add_base_arr.find(c)
		## If random chanse 1/2 matched: do colorize
		if randf() > 0.5:
			add_color_arr[i] = 0
	var color_to = normalize_color(body.color 
		+ Color(add_color_arr[0],add_color_arr[1],add_color_arr[2]))
	print(name, " is painted by ", add_color_arr, " to ", color_to)
	body.color = color_to
	return Vector3(
		add_color_arr[0],add_color_arr[1],add_color_arr[2]).normalized()


func normalize_color(raw_color: Color) -> Color:
	## Clamp below zero values
	raw_color.r = clampf(raw_color.r, 0, 2)
	raw_color.g = clampf(raw_color.g, 0, 2)
	raw_color.b = clampf(raw_color.b, 0, 2)
	var cv := Vector3(raw_color.r, raw_color.g, raw_color.b)
	## normalize 
	if cv.length() > 2 or cv.length() < 1:
		cv = cv.normalized()
	return Color(cv.x, cv.y, cv.z, 1)


func paint_color(body:CharacterBody2D, new_color:Color) -> void:
	body.find_child("Sprite2D").modulate = new_color
	body.find_child("Particles").color =  new_color * 0.8
	body.find_child("Cross").default_color = new_color * 0.8
	body.find_child("Cross").hide()
