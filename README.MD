# Godot 3 Cars 2d with Physics prototype
#### Create pull requests via:
* https://bitbucket.org/dcheva/v4-00-cars/pull-requests/new?source=_BRANCH_&t=1
* https://github.com/dcheva/v4-00-cars/pull/new/_BRANCH_
---
- Draw the car
- Implement simple arcade car physics 
- Add fonts
- Implement on_Player_set_hud(), set Camera.position, set_label(args)
- Begin generate sand background
- Fix sand "Browny" BG, overlay and variables
## Branch traces
- Add prototype tracks
- Add fullscreen to Main process
- Working tracks
## Branch statics
- Start proc-gen-world based on noise https://www.youtube.com/watch?v=rlUzizExe2Q
# v4-00-cars Github repo 
## Godot 4 restarted Cars 2d with Autogen prototype
- import, test and fix in Godot 4
- start generate procedural world using NoiseTexture2D
- create TileMapLayer in Godot4 to connect to generator
- New tilemap with 4 atlases for gravel, ground, grass-dry grass-green
- Autogen 512x512(32x32kPix) map with 4 Atlas tilemaps
- Decrease tiles size Set atlas_size:8 chunk_size:512(16000px=1.6km)
- Juicy Smooth camera and @TODO preload settings
- Fixed import and export errors
- Add 16 static piles on separate TileMapLayer (without collision!?)
- Lern Howto create collisions on TileMapLayer
- Create collisions on stones
- Statics: tilemap layer with stones/bushes/... based on height masks (23 in 0.1234)
- Add collisions physics on the car
- Start with the new car
- It works! \_on_timer_timeout(author)
- It works! Signals with ExtraCallArgument arg:string Main/NodeName->get_tree().get_root().get_node(arg)
- Implement NPC car with tracks. Now it needts to be refactored!
## Separate MD's for Branches: "statics", "physics" and "npc"
## Start refactor
- Implement preload functions via g = $loader
- Merge refactored Okama barber into initial
- Remove redundant raycast and other logic
- Add Timers and Triggers for generator.find_path
- ~~Start adding statics~~
- Deploy FSM from BehaviourToolkit
- Implement basic states and transitions
* /fsm-bt/ Start implement BT
* /sounds/ Realize fully-functional code-controlled AnimationPlayer with various engine sounds dependent on engine RPM