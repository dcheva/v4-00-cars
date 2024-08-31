extends StateMachineState

@export var player: CharacterBody2D

# Called when the state machine enters this state.
func on_enter() -> void:
	player.set_animation("Start").play_animation()
	print_debug("player.set_animation(Start)")

# Called every frame when this state is active.
func on_process(_delta: float) -> void:
	pass

# Called every physics frame when this state is active.
func on_physics_process(_delta: float) -> void:
	pass

# Called when there is an input _event while this state is active.
func on_input(_event: InputEvent) -> void:
	pass

# Called when the state machine exits this state.
func on_exit() -> void:
	player.set_animation("Stop").play_animation()
	print_debug("player.set_animation(Stop)")
