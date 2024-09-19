extends FSMState
## A state in a [FiniteStateMachine]. This is the base class for all states.
##
## It's a basic building block to build full State Machines, only one state
## held by [FiniteStateMachine] is active, to switch to a different state,
## a [FSMTransition] must be triggered or you can use FSM methods to switch
## states manually.
## To implement your logic you can override the [code]_on_enter, _on_update and
## _on_exit[/code] methods when extending the node's script.

var move_timer := 0.0


## Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	#### Continue from BaseNPC script	
	if actor.velocity.length() < 200:
		if actor.leader:
			var res = actor.set_global_target(actor.get_random_position())
			while !res:
				res = actor.set_global_target(actor.get_random_position())
		elif !actor.update_current_target():
			actor.set_current_target(actor.get_random_position())
		actor.animations.play("Move")


## Executes every process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	move_timer += delta
	if move_timer > 0.1:
		if (actor.update_current_target()
		or actor.leader and actor.global_target != Vector2.ZERO):
			actor.animations.play("Target")
		move_timer = 0.0
	


## Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
