extends CharacterBody2D

@export var dexta := 5.0
@export var speed := 200.0
@export var shift := 400.0


func _physics_process(delta: float) -> void:
	## Lerp physics
	velocity = lerp(velocity, get_input(delta) * speed, dexta * delta)
	move_and_slide()


func get_input(_delta) -> Vector2:
	
	## Arrows
	var velocity_to: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left_arrow"):
		velocity_to += Vector2.LEFT
	if Input.is_action_pressed("right_arrow"):
		velocity_to += Vector2.RIGHT
	if Input.is_action_pressed("up_arrow"):
		velocity_to += Vector2.UP
	if Input.is_action_pressed("down_arrow"):
		velocity_to += Vector2.DOWN
	velocity_to = velocity_to.normalized()
	
	## Modifiers
	if Input.is_action_pressed("shift"):
		velocity_to *= shift / speed

	return velocity_to
