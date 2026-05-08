class_name Trail extends Node2D

@export var lifetime: float = 0.0  # 0 = infinite (no trimming)
@export var width: float = 4.0
@export var color: Color = Color.WHITE

var _line: Line2D
var _times: PackedFloat32Array = []
var _colors: PackedColorArray = []
const GRACE_POINTS := 3

func _ready() -> void:
	_line = Line2D.new()
	_line.width = width
	_line.default_color = color
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	# Use gradient so each point keeps its color at the time it was drawn
	_line.gradient = Gradient.new()
	add_child(_line)

func append_point(pos: Vector2, now: float, col: Color = Color.WHITE) -> void:
	_line.add_point(_line.to_local(pos))
	_times.append(now)
	_colors.append(col)
	_rebuild_gradient()

func trim_expired(now: float) -> void:
	if lifetime <= 0.0:
		return  # infinite trail — never trim
	var cutoff := now - lifetime
	var remove_count := 0
	for i in _times.size():
		if _times[i] < cutoff:
			remove_count += 1
		else:
			break
	for i in remove_count:
		_line.remove_point(0)
	if remove_count > 0:
		_times = _times.slice(remove_count)
		_colors = _colors.slice(remove_count)
		_rebuild_gradient()

func segments() -> Array:
	var result: Array = []
	var pts := _line.points
	for i in pts.size() - 1:
		result.append(PackedVector2Array([_line.to_global(pts[i]), _line.to_global(pts[i + 1])]))
	return result

func segments_excluding_recent(n: int) -> Array:
	var result: Array = []
	var pts := _line.points
	var end := pts.size() - 1 - n
	for i in end:
		result.append(PackedVector2Array([_line.to_global(pts[i]), _line.to_global(pts[i + 1])]))
	return result

func _rebuild_gradient() -> void:
	var n := _colors.size()
	if n == 0:
		return
	var g := _line.gradient
	g.offsets = PackedFloat32Array()
	g.colors = PackedColorArray()
	for i in n:
		var t := float(i) / float(max(n - 1, 1))
		g.add_point(t, _colors[i])

func update_last_color(col: Color) -> void:
	var n := _colors.size()
	if n == 0:
		return
	_colors[n - 1] = col
	_rebuild_gradient()

func clear() -> void:
	_line.clear_points()
	_times = PackedFloat32Array()
	_colors = PackedColorArray()
	if _line.gradient:
		_line.gradient.offsets = PackedFloat32Array()
		_line.gradient.colors = PackedColorArray()
