extends StateMachineState

@export var player: CharacterBody2D

# Called when the state machine enters this state.
func on_enter() -> void:
	player.set_animation("Start").play_animation()
	print_debug("player.set_animation(Start)")


# Called every frame when this state is active.
func on_process(delta: float) -> void:
	print_debug()


# Called every physics frame when this state is active.
func on_physics_process(delta: float) -> void:
	print_debug()


# Called when there is an input event while this state is active.
func on_input(event: InputEvent) -> void:
	print_debug()


# Called when the state machine exits this state.
func on_exit() -> void:
	print_debug()
