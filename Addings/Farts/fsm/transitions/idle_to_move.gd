extends FSMTransition
## A transition between two [FSMState]s in a [FiniteStateMachine].
##
## This is the base class for all transitions. To implement your logic you can
## override the [code]_on_transition[/code] method when extending the node's
## script.[br]
## To setup custom conditions you can override the is_valid method.[br]
## If you want to use events to trigger the transition, set
## [code]use_event[/code] to true and set the event property to the name
## of the event you want to listen for.


## Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass


## ?## 100% on 3..6s idle
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	if (actor.velocity.length() < actor.speed / 2 
		and (
			actor.leader and actor.timer > 10
		) or (
			!actor.leader and actor.timer > 6 - randf() * 3
		)):
		## goes to Move State after 3..6s in Idle State
		actor.timer = 0.0
		return true
	return false


func is_valid_event(current_event: String) -> bool:
	if current_event == "":
		return false

	return current_event == event
