extends FSMTransition


## Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass


## 10s+: If it is too long to do
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	if !(actor.leader or actor.target_obj is CharacterBody2D) and actor.timer > 10:
		print("10s+: If it is too long to NPC's to do")
		return true
	if (actor.leader or actor.target_obj is CharacterBody2D) and actor.timer > 20:
		print("20s+: If it is too long to Leader's to do")
		return true
	return false


func is_valid_event(current_event: String) -> bool:
	if current_event == "":
		return false

	return current_event == event
