class_name Arena extends Node2D

const MARGIN := 40.0
var rect: Rect2

func _ready() -> void:
	var vp := get_viewport_rect()
	rect = Rect2(MARGIN, MARGIN, vp.size.x - MARGIN * 2.0, vp.size.y - MARGIN * 2.0)
	queue_redraw()

func _draw() -> void:
	draw_rect(rect, Color(0.3, 0.3, 0.3), false, 3.0)

func is_inside(pos: Vector2) -> bool:
	return rect.has_point(pos)
