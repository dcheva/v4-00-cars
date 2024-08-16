extends Node

var cam = Vector2()

@export var Track_S = preload("res://Track_S.tscn")
@export var Track_L = preload("res://Track_S.tscn")


func _ready():
	$DrawTrack.start()


func _process(_delta):
	if Input.is_action_just_pressed("alt_enter"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))  ) else Window.MODE_WINDOWED


func _on_Player_set_hud():
	var pos = $Player.position
	var rot = $Player.rotation_degrees
	var vel = $Player.velocity
	var speed = $Player.speed
	var steer = $Player.steer
	var trk = get_tree().get_nodes_in_group("track").size()
	cam = pos + Vector2(int(vel.x),int(vel.y/2))
	set_label([pos,rot,vel,speed,steer,cam,trk])
	$Camera3D.position = cam


func set_label(args):
	var l = $Canvas/Control/Label
	l.text =  "X, Y     : %s, %s\n" % [int(args[0][0]), int(args[0][1])]
	l.text += "Speed    : %s\n" % int(args[3])
	l.text += "Steering : %s\n" % int(args[4])
	l.text += "Rotation : %s\n" % int(args[1])
	l.text += "Velocity : %s, %s\n" % [int(args[2][0]), int(args[2][1])]
	l.text += "Camera3D   : %s, %s\n" % [int(args[5][0]), int(args[5][1])]
	l.text += "Tracks   : %s\n" % args[6]


func _on_DrawTrack_timeout():
	# Instantiate and draw tracks on the main scene
	var track
	if abs($Player.speed) > $Player.truck_l_speed:
		track = Track_L.instantiate()
	else:
		track = Track_S.instantiate()
	track.position = $Player.position
	track.rotation = $Player.rotation
	track.z_index = $Player.z_index - 1
	add_child(track)
	_set_draw_timer()

func _on_Player_set_draw_timer():
	_set_draw_timer()
		
func _set_draw_timer():
	var w = $Player.draw_truck_timer_formula()
	if $DrawTrack.is_stopped() or $DrawTrack.time_left > 1:
		$DrawTrack.start(w)
