extends FSMState


# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):
	# Cast actor
	actor = actor as CharacterBody2D
	#print_debug()

	actor.animation_player.play("Start")
	var await_time: float = actor.animation_player.current_animation_length
	await get_tree().create_timer(await_time).timeout


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(_actor, _blackboard: Blackboard):
	pass
