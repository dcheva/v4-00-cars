extends BTLeaf
## A leaf is where the actual logic that controlls the actor or other nodes
## is implemented.
##
## It is the base class for all leaves and can be extended to implement
## custom behaviours.[br]
## The [code]tick(actor: Node, blackboard: Blackboard)[/code] method is called
## every frame and should return the status.


var bt_tick: int


func tick(_delta: float, actor: Node, blackboard: Blackboard) -> BTStatus:
	var timer: float = blackboard.get_value("timer")
	bt_tick = blackboard.get_value("bt_tick")
	
	## If not initializes BlackBoard variables
	if timer == null or randf() > 0.5:
		return BTStatus.FAILURE
		
	## Start speak in 1%3 ticks and not leader
	## Or start speak in 1%6 ticks if is leader
	if (bt_tick % 5 < 4):
		start_actor_logic(timer, actor, blackboard)
	
	## Update ticker and exit with SUCCESS
	bt_tick += 1
	blackboard.set_value("bt_tick", bt_tick)
	return BTStatus.SUCCESS
	
	
## Working for each 1 sec (2 leafs in 2 seconds)
func start_actor_logic(
	_timer: float, actor: Node, _blackboard: Blackboard) -> void:
	print (actor.name, " is Speaking...")
	actor.reset_to_idle(2)
	actor.particles.color = actor.color / 2 
	actor.animations.play("Speak")
	
