extends FSMTransition

# Executed when the transition is taken.
func _on_transition(_delta, _actor, _blackboard: Blackboard):
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor, _blackboard: Blackboard):
	# Cast actor
	actor = actor as CharacterBody2D
	
	if (Input.is_action_pressed("up_arrow") 
		and not Input.is_action_pressed("shift")):
		return true
	return false
