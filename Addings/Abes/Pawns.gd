extends CharacterBody2D


var speed      := 640.0
var direction  := Vector2.ZERO
var abes       := []
	

func _ready() -> void:
	## Initial direction
	if(global_position.x < 640):
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	## A little bit random
	velocity.x  += direction.x * speed * randf()
	speed *= randf_range(0.8,1.2)
	
	## Append attachable
	abes.append(attachable("Diffuse"))


func _physics_process(delta: float) -> void:
	## Bob movement
	if global_position.x <= (512):
		direction = Vector2.RIGHT
	if global_position.x >= (1280-512):
		direction = Vector2.LEFT
	velocity  += direction * speed * delta
	velocity.x = clamp(velocity.x, -speed, speed)
	move_and_slide()
	
	## Call attachable.execute()
	if(randf() < delta):
		var args: Dictionary
		if name == "p1":
			args.from = get_parent().find_child("p1")
			args.to = get_parent().find_child("p2")
			args.color = Color.CYAN
		else:
			args.from = get_parent().find_child("p2")
			args.to = get_parent().find_child("p1")
			args.color = Color.MAGENTA
		args.amount = randi_range(5, 25)
		var res = abes[0].execute(args)
		## Print the answer result
		if res != {}:
			print(res)
	
	
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
