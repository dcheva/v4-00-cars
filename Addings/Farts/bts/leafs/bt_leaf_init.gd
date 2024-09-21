extends BTLeaf
## Init Blackboard variables

func tick(_delta: float, _actor: Node, blackboard: Blackboard) -> BTStatus:
	var timer = blackboard.get_value("timer")
	if timer == null:
		blackboard.set_value("timer", 0.0)
		blackboard.set_value("bt_tick", 0)
		## \\ !Add more variables here! // ##
		print("-= Blackboard initialised =-")
	return BTStatus.SUCCESS
