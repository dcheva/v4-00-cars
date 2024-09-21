extends AudioStreamPlayer


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("enter"):
		_play(0.0)


func _play(from_position:float=0.0) -> void:
	randomize()
	self.pitch_scale = randf_range(0.5,2.0)
	self.play(from_position)
	
