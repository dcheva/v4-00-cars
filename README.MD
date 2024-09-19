# Godot 3 Cars 2d with Physics prototype
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
- Deploy FSM from BehaviourToolkit
- Implement basic states and transitions
- Try to commit as cheva@github
- Refactor proc_gen_world and merge
- Add hide_npc and hide_cpu to improve testing efficiency
- Test final FSM with gearbox and Merge Sounds branch
## Start compose
- Instantiate Farts in the World and test It Works!
