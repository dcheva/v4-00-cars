### Backlog: Planned to implement
1. ...NPC follower - add the car with input interface the NPC driver class
2. Roads: A-star to find path in height range on noisemap: increase range to find path
3. Threaded generation of chunks: generate chunks on triggered distance, delete old
4. Preload settings
5. Implement chat messages with console input and use it like print()
6. Add DSL to chat commands (DCL)
---
### TODO NOW
NPC follower - add the car with input interface the NPC driver class:

1. Create obs_arr instead of rocks
2. Implement create_obs_layer with lines (walls) and points (rocks, trees, ...)
3. Implement NPC logic:
  - Find the player on the minimap and draw the route A*
  - When the player becomes visible - run one of the FollowMe algorithms:
    - Interception
    - Approach
    - Pursuit
