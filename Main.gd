extends Node2D

@onready var player_driver := $Player
@onready var player_driver_timer := $Player/DrawTrack
@onready var generator = $proc_gen_world
@onready var label = $Canvas/Control/Label
@onready var npc_driver := $NPC
@onready var npc_driver_timer := $NPC/DrawTrack
@export var hide_npc := true

# @TODO preload settings
@export var cam_sensitivity = 0.05
@export var cam_distance = 1
@export var cam_x_speed = 1.4
var cam := Vector2()


func _ready():
	if hide_npc:
		npc_driver.queue_free()
	else:
		npc_driver.player = player_driver
		npc_driver.tilemap_path = generator.tilemap_path
		npc_driver.generator = generator
	start_drivers()
	

func _process(_delta):
	if Input.is_action_just_pressed("alt_enter"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))  ) else Window.MODE_WINDOWED


func start_drivers() -> void:
	player_driver_timer.start()
	if not hide_npc:
		npc_driver_timer.start()


func _on_Player_set_hud():
	var pos = player_driver.position
	var rot = player_driver.rotation_degrees
	var vel = player_driver.velocity
	var speed = player_driver.speed
	var steer = player_driver.steer
	var trk = get_tree().get_nodes_in_group("track").size()
	var npc := ""
	var plr := ""
	if not hide_npc:
		npc = npc_driver.pos2l # npc current target
		plr = npc_driver.printed + "\n" # plr from npc astar position
	# Set camera position @TODO move this code
	var cam_to = pos + Vector2(int(vel.x * cam_x_speed * cam_distance),int(vel.y * cam_distance))
	cam = lerp(cam, cam_to, cam_sensitivity)
	$Camera2D.position = cam
	set_label([pos,rot,vel,speed,steer,cam,trk,npc,plr])


func set_label(args):
	var l = label
	l.text =  "X,.Y.....: %s, %s\n" % [int(args[0][0]), int(args[0][1])]
	l.text += "Speed....: %s\n" % int(args[3])
	l.text += "Steering.: %s\n" % int(args[4])
	l.text += "Rotation.: %s\n" % int(args[1])
	l.text += "Velocity.: %s, %s\n" % [int(args[2][0]), int(args[2][1])]
	l.text += "Camera...: %s, %s\n" % [int(args[5][0]), int(args[5][1])]
	l.text += "Tracks...: %s\n" % args[6]
	if not hide_npc:
		#l.text += "Target,m.: %s\n" % int(args[7]/10) # npc current target
		l.text += "%s\n" % args[8] # plr from npc astar position


func _set_draw_timer(author: CharacterBody2D):
	var DrawTime = author.draw_track_timer_formula()
	var DrawTrack = author.find_child("DrawTrack")
	if DrawTrack.is_stopped() or DrawTrack.time_left > 1:
		#print(author)
		#print(DrawTime)
		DrawTrack.start(DrawTime)


func _on_draw_track_timeout(arg: String) -> void:
	# Instantiate and draw tracks on the main scene
	var track
	var author = get_tree().get_root().get_node(arg)
	if abs(author.speed) > author.opt_speed:
		track = author.Track_L.instantiate()
	else:
		track = author.Track_S.instantiate()
	track.position = author.position
	track.rotation = author.rotation
	track.z_index = author.z_index - 1
	add_child(track)
	_set_draw_timer(author)


func _on_npc_set_draw_timer() -> void:
	if not hide_npc:
		_set_draw_timer(npc_driver)


func _on_Player_set_draw_timer() -> void:
	_set_draw_timer(player_driver)
