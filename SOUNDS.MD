# Implement Sound Player via AnimationPlayer
## Use Branch sounds
- Implement pitch_shift via AudioServer.get_bus_effect(AudioServer.get_bus_index("PlayerEngine"),0)

	# Play right sound !!!IMPORTANT!!!
	var sound_pitch: float = clamp(abs(speed) / opt_speed, 0.5, 2)
	var as_id := AudioServer.get_bus_index("PlayerEngine")
	var as_ef := AudioServer.get_bus_effect(as_id, 0)
	as_ef.pitch_scale = sound_pitch
	print(as_ef.pitch_scale)