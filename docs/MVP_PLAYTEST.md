# MVP Playtest Checklist

## Setup
- [ ] Launch the game via Godot 4 editor or exported binary
- [ ] Title screen appears on a black background with "TOFESET" heading
- [ ] Controls hint visible: "P1: WASD  P2: Arrow Keys"

## Match Start
- [ ] Press Space/Enter → countdown 3-2-1 appears then disappears
- [ ] Both dots spawn at opposite sides of the arena (cyan left, magenta right)
- [ ] HUD shows "P1: 0 — P2: 0" and role badges (CHASER / RUNNER)
- [ ] Both dots begin moving immediately after countdown

## Movement & Trail
- [ ] P1 (WASD) moves smoothly in 8 directions at constant speed
- [ ] P2 (Arrow keys) moves smoothly in 8 directions at constant speed
- [ ] Each dot leaves a coloured Line2D trail behind it
- [ ] Trail points older than ~4 s visibly disappear from the oldest end
- [ ] Trail never exceeds ~250 points (no visible lag)

## Collision — Boundary
- [ ] Drive P1 into the arena edge → round ends, P2 wins
- [ ] Drive P2 into the arena edge → round ends, P1 wins
- [ ] Round-end overlay shows correct winner and "Out of bounds!"

## Collision — Trail Crash
- [ ] Drive P1 into P1's own trail → P1 loses, P2 wins, overlay shows "Hit a trail!"
- [ ] Drive P1 into P2's trail → P1 loses, P2 wins, overlay shows "Hit a trail!"
- [ ] No instant self-collision at spawn (grace window active)

## Collision — Catch
- [ ] Chaser dot touches Runner dot → Chaser wins, overlay shows "Caught!"
- [ ] Head-on simultaneous contact → Chaser wins (no crash, no double-elimination)

## Role Swap
- [ ] After round 1: P1 was Chaser → P1 becomes Runner in round 2
- [ ] HUD role badges update correctly each round

## Scoring & Match End
- [ ] Score increments correctly after each round
- [ ] First player to 3 wins triggers match-end screen
- [ ] Match-end screen shows correct winner and final score
- [ ] Press Space/Enter on match-end → new match starts from 0-0
- [ ] Press Esc on match-end → game quits

## Adaptive Audio
- [ ] A synthesised tone plays as soon as the round starts
- [ ] Tone repeats slowly when dots are far apart (~80 BPM)
- [ ] Tone accelerates noticeably as dots approach (~240 BPM at closest)
- [ ] Audio fades out cleanly at round end (no click/pop)
- [ ] No audio buffer underrun errors in Godot output log

## Edge Cases
- [ ] Window loses focus mid-round → audio pauses, no crash on resume
- [ ] Play 9 rounds (max possible) → no memory growth, no leaked Line2D nodes
- [ ] Pressing opposite directions simultaneously → heading is deterministic (no freeze)

## Performance
- [ ] Stable 60 FPS throughout a full match at 1920×1080
- [ ] No frame drops when both trails are at maximum length (~250 pts each)
