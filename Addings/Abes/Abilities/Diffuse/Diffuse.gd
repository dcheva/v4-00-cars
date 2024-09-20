extends Node2D


## Variables
var square: Polygon2D = find_child("Square")
var square_speed = 10.0
## Cooldown timer
var timer: Timer
## Arguments
var from: CharacterBody2D
var to: CharacterBody2D
var color: Color
var amount: int
var child_to = get_parent().get_parent()


## @INTERFACE execute(args: Dictionary) -> Dictionary:
func execute(args: Dictionary) -> Dictionary:
	var res: Dictionary
	## Check cooldown timer
	if timer != null:
		print("Cool down ", to)
		return res
	## Get arguments
	from = args.from
	to = args.to
	amount = args.amount
	color = args.color
	## Instatiate diffusion
	start_timer()
	for i in amount:
		var square_node = square.duplicate()
		## Add to global positioned node
		print(child_to)
		child_to.add_child(square_node)
		square_node.add_to_group("diffuse")
		square_node.add_to_group("to" + to.name)
		square_node.color = color
		square_node.z_index = 600
		square_node.global_position = global_position
		square_node.global_position += Vector2(randf_range(-64,64),randi_range(-64,64))
		square_node.show()
	## Return result
	res.name = to
	res.count = get_tree().get_nodes_in_group("to" + to.name).size()
	return res


## It doesn't work here, but it can be forced using instance.set_process(true)
func _process(delta: float) -> void:
	## To avoid empty startup errors
	if (from != null and to != null and 
			get_tree().get_nodes_in_group("to" + to.name).size() > 0):
		## Iteration of diffusion parts
		for child in child_to.get_children():
			if child.is_in_group("to" + to.name):
				var rfd := randf() * delta
				## If the destination is reached
				if (child.global_position - to.global_position).length() < 32:
					child.queue_free()
				else:
					## Move manually because move_and_slide does not exist
					child.global_position = lerp(
						child.global_position, to.global_position, 
						rfd + square_speed * rfd)

## Create and start a timer manually
func start_timer() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", _on_timer_timeout)

## Manually too
func _on_timer_timeout() -> void:
	timer.queue_free()
