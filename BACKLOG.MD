### Backlog: Planned to implement
1. + NPC follower - add the car with input interface the NPC driver class
2. Roads: A-star to find path in height range on noisemap: increase range to find path
3. Threaded generation of chunks: generate chunks on triggered distance, delete old
4. Preload settings
---
### TODO NOW
* ...A* NPC navigation 
* Potato targets to hunt (groups, FSM and BT)
#### Realisation:
1. Implement !!!NPC!!! not world logic:
  * Find the player on the minimap and draw the route A*
  * When the player becomes visible - run one of the FollowMe algorithms:
    * Interception
    * Approach
    * Pursuit
