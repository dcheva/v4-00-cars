extends CharacterBody2D


@export var dexta := 2.0
@export var speed := 200.0 * 50 /Engine.physics_ticks_per_second
@export var shift := 400.0 * 50 /Engine.physics_ticks_per_second
@export var lead_vector := Vector3.ZERO
@export var global_target_map := Vector2.ZERO
@export var state : StringName


var leader := false

var main: Node
var generator: Node
var tile_size: Vector2
var chunk_size: int
var half_chunk: int
var quarter_chunk: int
var eighth_chunk: int

var camera: Camera2D
var func_get_astar_path: Callable
var func_get_free_static_cells: Callable
var astar_array: Array
var timer: float = 0.0
var global_center : Vector2
var target : Vector2
var target_obj: CharacterBody2D
var farts_burning_area: Vector2
var farts_liveing_area: Vector2
var farts_droping_area: Vector2
var state_machine : FiniteStateMachine
var animations : AnimationPlayer
var particles : CPUParticles2D
var sounds : AudioStreamPlayer2D
var abes : Array
var color : Color:
	set(val):
		paint_color(self, val)
		color = val


func _ready() -> void:
	main = get_parent().get_parent().get_parent()
	generator = main.find_child("proc_gen_world")
	chunk_size = generator.chunk_size
	half_chunk = generator.half_chunk
	quarter_chunk = generator.quarter_chunk
	eighth_chunk = generator.eighth_chunk
	set_color(pick_random_color())
	#print(name, " ready: ", color)
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
	var rand_vect = Vector3(randf(),randf(),randf()).normalized()
	return Color(rand_vect.x, rand_vect.y, rand_vect.z)


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
	target = new_target * tile_size + tile_size / 2
	astar_array = get_static_astar(target)
	return astar_array.size() > 0
	
func set_global_target_map(new_target: Vector2 = Vector2.ZERO) -> bool:
	if new_target != Vector2.ZERO:
		global_target_map = get_random_position(new_target)
		target = global_target_map * tile_size + tile_size / 2
		astar_array = get_static_astar(target)
		return astar_array.size() > 0
	else: 
		global_target_map = global_position / (tile_size + tile_size / 2)
		target = global_position 
		return false
	

func update_current_target() -> bool:
	if target_obj is CharacterBody2D:
		target = target_obj.global_position
	elif global_target_map != Vector2.ZERO:
		target =  get_random_position(global_target_map) * tile_size + tile_size/2
	else:
		return false
	astar_array = get_static_astar(target)
	if astar_array.size() <= 2:
		var t := ""
		if target_obj:
			if target_obj.leader:
				t += "Leader: "
			else:
				t += "Target Obj: "
			t += target_obj.name + " Pos: "
		else:
			t += "Target Pos: "
		print(name, " Reached ", t, " in time: ",
		"now" if int(timer) == 0 else "%s" % int(timer))
		target_obj = null
		reset_to_state("Success")
		return false
	else:
		return true
	
	
func get_random_position(def_pos := Vector2.ZERO) -> Vector2:
	randomize()
	var free_cells: Array[Vector2] = func_get_free_static_cells.call()
	var rand_pos = free_cells.pick_random()
	var test_area := quarter_chunk - eighth_chunk
	if def_pos != Vector2.ZERO:
		var i := 0
		while (rand_pos - def_pos).length() > test_area:
			i += 1
			test_area += i
			rand_pos = free_cells.pick_random()
	var res_pos = global_center / (tile_size + tile_size / 2) + rand_pos 
	return res_pos


func set_random_global_position(def_pos := Vector2.ZERO) -> void:
	global_position = get_random_position(def_pos) * tile_size + tile_size / 2


func get_static_astar(targeted: Vector2) -> Array:
	## Get Astar Statics navigation array from Current position to Target position
	var targeted_astar_array = func_get_astar_path.call(
		global_position, targeted)
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
		var color_amount = int(color_vector.length() * 5 + 5) # 5..10..15

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

	
func attachable(abe_name: StringName, _args: Array = []) -> Node:
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
	#print("Node \"", name, "\" attached ", abe_name, _args)
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
	if (body.find_child("Sprite2D") 
	and body.find_child("Particles")
	and body.find_child("Cross")):
		body.find_child("Sprite2D").modulate = new_color
		body.find_child("Particles").color =  new_color * 0.8
		body.find_child("Cross").default_color = new_color * 0.8
		body.find_child("Cross").hide()
