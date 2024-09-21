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
		
	##Else start listen in 2%3 ticks if not leader
	#if (bt_tick % 3 < 2 and not actor.leader):
	## Working for each tick
	start_actor_logic(timer, actor, blackboard)
	
	## Update ticker and exit with SUCCESS
	bt_tick += 1
	blackboard.set_value("bt_tick", bt_tick)
	return BTStatus.SUCCESS
	
	
## Working for each tick
func start_actor_logic(_timer: float, actor: Node, _blackboard: Blackboard) -> void:
	print (actor.name, " is Listening...")
	## Now find is anyone's speaking and set as the target
	## Otherway find random NPC as the target
	var world = actor.get_parent()
	for world_child in world.get_children():
		if (world_child.is_in_group("NPC") 
		and world_child != actor 
		and (
			## Is speaking
			world_child.animations.get_current_animation() == "Speak"
			## OR is the Leader
			or world_child.leader
			)
		):
			var t := ""
			if world_child.leader: 
				t += "...Found LEADER!!!"
				## Get Global Target from Leader
				actor.global_target_map = world_child.global_target_map
			else:
				t += "...Found Speaking"
			print (t, ": ", world_child.name, 
			" at ", world_child.global_position)
			## Set world_child as current target to start Move
			actor.reset_to_target(world_child)
			actor.timer = 0.0
