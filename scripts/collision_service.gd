extends Node

const GRACE_POINTS := 8
const DOT_SIZE := 14.0

var _arena = null

func set_arena(arena) -> void:
	_arena = arena

func check(players: Array) -> void:
	if _arena == null:
		return

	# Collect eliminations to avoid double-processing
	var eliminations: Array = []

	for i in players.size():
		var p = players[i]
		if not p.alive:
			continue

		# 1. Bounds check
		if not _arena.is_inside(p.global_position):
			eliminations.append({ "player": p, "cause": &"out_of_bounds" })
			continue

	# 2. Chaser catches Runner (dot-vs-dot)
	if players.size() == 2:
		var p0 = players[0]
		var p1 = players[1]
		if p0.alive and p1.alive:
			var dist: float = p0.global_position.distance_to(p1.global_position)
			if dist < DOT_SIZE:
				# Chaser wins — eliminate runner
				var runner = p1 if p0.role == 0 else p0  # Role.CHASER == 0
				eliminations.append({ "player": runner, "cause": &"caught" })

	# Apply eliminations — chaser-wins takes priority over simultaneous hits
	var runner_caught := eliminations.any(func(e): return e["cause"] == &"caught")
	for entry in eliminations:
		var ep = entry["player"]
		var cause: StringName = entry["cause"]
		if runner_caught and cause != &"caught":
			continue
		ep.eliminate(cause)
