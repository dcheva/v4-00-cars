extends Node2D

@export var base_npc_tscn: PackedScene
@export var base_npc_gd: Script
@onready var astar: Node = $Astar

## @HERE STUCKS thease wars are null in _ready()
var main: Node
@onready var camera: Camera2D 
@onready var generator: Node2D 
@onready var static_tile_size: Vector2
@onready var statics : TileMapLayer


func mfind() -> Node:
	return get_parent().get_parent()


func _ready() -> void:
	## @HERE it works
	main = get_parent().get_parent()
	camera = main.find_child("Camera2D")
	generator = main.find_child("proc_gen_world")
	static_tile_size = main.static_tile_size
	statics = generator.find_child("StaticTileMapLayer")
	astar.global_center = Vector2.ZERO
	astar.static_tilemap_layer = statics
	astar.static_tile_size = static_tile_size
	
	## Instantiate NPC's
	inst_npcs(10)
	## Set AStar
	astar.set_astar()
	## Init all in group NPC's
	init_npcs()


## Instatiate NPCs
func inst_npcs(q:int) -> void:
	for i in q:
		var new_npc = base_npc_tscn.instantiate()
		## Randomise spawn initial position
		new_npc.position = Vector2(10000,10000)
		add_child(new_npc, true)
		new_npc.add_to_group("NPC")
		new_npc.set_script(base_npc_gd)
		new_npc.set_physics_process(true)


## Initialize NPCs
func init_npcs() -> void:
	for child in get_children():
		## Check is it new NPC
		if child.is_in_group("NPC") and child.timer == 0.0:
			## Link variables and functions
			child.tile_size = statics.tile_set.tile_size
			child.camera = camera
			child.func_get_astar_path = astar.get_astar_path
			child.func_get_free_static_cells = astar.get_free_static_cells
			child.global_center = astar.global_center
			## Start FSM 
			child.state_machine = child.find_child("FSM")
			child.state_machine.start()
			## Animation player
			child.animations = child.find_child("Animations")
			child.particles = child.find_child("Particles")
			child.sounds = child.find_child("Sounds")
			child.animations = child.find_child("Animations")
			child.animations.play("Idle")
			child.set_as_leader(child, false)
			## Randomise position and target
			child.set_random_position()
			child.set_current_target(child.get_random_position())


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Spawn"):
		inst_npcs(1)
		init_npcs()
		
