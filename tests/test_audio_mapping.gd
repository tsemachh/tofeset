extends Node

# Run with: godot --headless --script tests/test_audio_mapping.gd

var _passed := 0
var _failed := 0

const BPM_MIN := 80.0
const BPM_MAX := 240.0

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

func assert_approx_eq(a: float, b: float, tolerance: float, msg: String) -> void:
	assert_true(abs(a - b) <= tolerance, "%s (got %.2f, expected %.2f)" % [msg, a, b])

func distance_to_bpm(d: float, d_min: float, d_max: float) -> float:
	if d_max <= d_min:
		return BPM_MAX
	var t := clampf((d - d_min) / (d_max - d_min), 0.0, 1.0)
	return lerpf(BPM_MAX, BPM_MIN, t)

func _run_all() -> void:
	print("=== test_audio_mapping.gd ===")
	_test_at_min_distance()
	_test_at_max_distance()
	_test_at_midpoint()
	_test_below_min_clamps()
	_test_above_max_clamps()
	_test_monotonic_decreasing()

func _test_at_min_distance() -> void:
	var bpm := distance_to_bpm(0.0, 0.0, 1000.0)
	assert_approx_eq(bpm, BPM_MAX, 0.01, "at min distance BPM = MAX (240)")

func _test_at_max_distance() -> void:
	var bpm := distance_to_bpm(1000.0, 0.0, 1000.0)
	assert_approx_eq(bpm, BPM_MIN, 0.01, "at max distance BPM = MIN (80)")

func _test_at_midpoint() -> void:
	var bpm := distance_to_bpm(500.0, 0.0, 1000.0)
	assert_approx_eq(bpm, (BPM_MIN + BPM_MAX) / 2.0, 0.01, "at midpoint BPM = 160")

func _test_below_min_clamps() -> void:
	var bpm := distance_to_bpm(-100.0, 0.0, 1000.0)
	assert_approx_eq(bpm, BPM_MAX, 0.01, "below min distance clamps to MAX BPM")

func _test_above_max_clamps() -> void:
	var bpm := distance_to_bpm(2000.0, 0.0, 1000.0)
	assert_approx_eq(bpm, BPM_MIN, 0.01, "above max distance clamps to MIN BPM")

func _test_monotonic_decreasing() -> void:
	var prev := distance_to_bpm(0.0, 0.0, 1000.0)
	var monotonic := true
	for i in 10:
		var d := float(i + 1) * 100.0
		var bpm := distance_to_bpm(d, 0.0, 1000.0)
		if bpm > prev + 0.001:
			monotonic = false
			break
		prev = bpm
	assert_true(monotonic, "BPM decreases monotonically as distance increases")
