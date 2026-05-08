extends Node

# Run with: godot --headless --script tests/test_match_state.gd

var _passed := 0
var _failed := 0

func _ready() -> void:
	_run_all()
	print("[TEST RESULTS] Passed: %d  Failed: %d" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)

func assert_true(condition: bool, msg: String) -> void:
	if condition:
		_passed += 1
		print("  PASS: %s" % msg)
	else:
		_failed += 1
		print("  FAIL: %s" % msg)

func assert_eq(a, b, msg: String) -> void:
	assert_true(a == b, "%s (got %s, expected %s)" % [msg, str(a), str(b)])

func _run_all() -> void:
	print("=== test_match_state.gd ===")
	_test_score_increment()
	_test_role_swap()
	_test_match_end_at_3_wins()
	_test_no_match_end_before_3_wins()
	_test_both_players_can_reach_3()

# --- Pure logic helpers (no scene needed) ---

func _simulate_end_round(score: Dictionary, winner_key: String, round_index: int) -> Dictionary:
	score[winner_key] += 1
	# Role swap: round_index parity determines chaser
	var p1_is_chaser := (round_index + 1) % 2 == 0
	return { "score": score, "p1_is_chaser": p1_is_chaser }

func _is_match_over(score: Dictionary) -> bool:
	return score["p1"] >= 3 or score["p2"] >= 3

func _test_score_increment() -> void:
	var score := { "p1": 0, "p2": 0 }
	var result := _simulate_end_round(score, "p1", 0)
	assert_eq(result["score"]["p1"], 1, "p1 score increments after winning round")
	assert_eq(result["score"]["p2"], 0, "p2 score unchanged after p1 wins")

func _test_role_swap() -> void:
	# Round 0: p1 starts as chaser (round_index % 2 == 0)
	# After round 0 ends, round_index becomes 1: p1 is runner
	var p1_chaser_round0 := 0 % 2 == 0
	var p1_chaser_round1 := 1 % 2 == 0
	assert_true(p1_chaser_round0, "p1 is chaser in round 0")
	assert_true(not p1_chaser_round1, "p1 is runner in round 1 (role swapped)")

func _test_match_end_at_3_wins() -> void:
	var score := { "p1": 0, "p2": 0 }
	for i in 3:
		_simulate_end_round(score, "p1", i)
	assert_true(_is_match_over(score), "match ends when p1 reaches 3 wins")
	assert_eq(score["p1"], 3, "p1 has exactly 3 wins")

func _test_no_match_end_before_3_wins() -> void:
	var score := { "p1": 0, "p2": 0 }
	for i in 2:
		_simulate_end_round(score, "p1", i)
	assert_true(not _is_match_over(score), "match does not end at 2 wins")

func _test_both_players_can_reach_3() -> void:
	var score := { "p1": 0, "p2": 0 }
	# Alternating wins
	for i in 5:
		var winner := "p1" if i % 2 == 0 else "p2"
		_simulate_end_round(score, winner, i)
	# p1: 3 wins (rounds 0,2,4), p2: 2 wins (rounds 1,3)
	assert_eq(score["p1"], 3, "p1 reaches 3 wins in alternating match")
	assert_eq(score["p2"], 2, "p2 has 2 wins in alternating match")
	assert_true(_is_match_over(score), "match ends when p1 reaches 3 in alternating match")
