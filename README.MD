# Godot 3 Cars 2d with Physics prototype
- Draw the car
- Implement simple arcade car physics 
- Add fonts
- Implement _on_Player_set_hud(), set Camera.position, set_label(args)
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
### Backlog: Planned to implement
1. Roads: A-star to find path in height range on noisemap: increase range to find path
2. Statics: tilemap layer with stones/bushes/... based on height masks (23 in 0.1234)
3. Threaded generation of chunks: generate chunks on triggered distance, delete old
4. Preload settings

- Juicy Smooth camera and @TODO preload settings
- Fixed import and export errors
- Add 16 static piles on separate TileMapLayer (without collision!?)
- Lern Howto create collisions on TileMapLayer
### Backlog: Planned to implement
1. NPC follower - add the car with input interface the NPC driver class
2. Implement chat messages with console input and use it like print()
3. Add DSL to chat commands (DCL)

- Start with one more car
