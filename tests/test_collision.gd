extends Node

# Minimal hand-rolled test runner for headless GDScript unit tests.
# Run with: godot --headless --script tests/test_collision.gd

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

func assert_false(condition: bool, msg: String) -> void:
	assert_true(not condition, msg)

func assert_null(val, msg: String) -> void:
	assert_true(val == null, msg)

func assert_not_null(val, msg: String) -> void:
	assert_true(val != null, msg)

func _run_all() -> void:
	print("=== test_collision.gd ===")
	_test_segment_hit()
	_test_segment_miss()
	_test_segment_endpoint_touch()
	_test_segment_collinear()
	_test_arena_inside()
	_test_arena_outside()
	_test_arena_on_edge()

func _test_segment_hit() -> void:
	# Two crossing segments — should intersect
	var a1 := Vector2(0, 0)
	var a2 := Vector2(10, 10)
	var b1 := Vector2(0, 10)
	var b2 := Vector2(10, 0)
	var hit = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	assert_not_null(hit, "crossing segments intersect")

func _test_segment_miss() -> void:
	# Parallel non-overlapping segments — should not intersect
	var a1 := Vector2(0, 0)
	var a2 := Vector2(10, 0)
	var b1 := Vector2(0, 5)
	var b2 := Vector2(10, 5)
	var hit = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	assert_null(hit, "parallel segments do not intersect")

func _test_segment_endpoint_touch() -> void:
	# Segments sharing an endpoint
	var a1 := Vector2(0, 0)
	var a2 := Vector2(5, 5)
	var b1 := Vector2(5, 5)
	var b2 := Vector2(10, 0)
	var hit = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	assert_not_null(hit, "endpoint-touching segments intersect")

func _test_segment_collinear() -> void:
	# Collinear non-overlapping segments — Godot returns null for these
	var a1 := Vector2(0, 0)
	var a2 := Vector2(4, 0)
	var b1 := Vector2(6, 0)
	var b2 := Vector2(10, 0)
	var hit = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	assert_null(hit, "collinear non-overlapping segments do not intersect")

func _test_arena_inside() -> void:
	var r := Rect2(40, 40, 1840, 1000)
	assert_true(r.has_point(Vector2(960, 540)), "center point is inside arena")

func _test_arena_outside() -> void:
	var r := Rect2(40, 40, 1840, 1000)
	assert_false(r.has_point(Vector2(10, 10)), "corner point is outside arena")

func _test_arena_on_edge() -> void:
	var r := Rect2(40, 40, 1840, 1000)
	# Rect2.has_point treats right/bottom edge as outside
	assert_false(r.has_point(Vector2(40 + 1840, 540)), "right edge is outside arena")
