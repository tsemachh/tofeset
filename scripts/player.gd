class_name Player extends Node2D

enum Role { CHASER, RUNNER }

@export var speed: float = 220.0
@export var input_prefix: String = "p1"
@export var color: Color = Color.CYAN

var role: Role = Role.RUNNER
var heading: Vector2 = Vector2.RIGHT
var alive: bool = true
var last_position: Vector2

var _trail: Trail
var arena_rect: Rect2 = Rect2()

# Color cycling
var _hue: float = 0.0
var _hue_speed: float = 0.6  # full cycle in ~1.67 s; offset per player set in setup()
var _current_color: Color = Color.CYAN

signal eliminated(cause: StringName)

const DOT_RADIUS := 14.0


func init_trail(parent: Node) -> void:
	_trail = Trail.new()
	_trail.width = DOT_RADIUS * 2.0
	_trail.lifetime = 0.0  # infinite — trail never disappears
	parent.add_child(_trail)

func _update_trail_width() -> void:
	if _trail:
		_trail._line.width = DOT_RADIUS * 2.0

func setup(p_role: Role, p_color: Color, p_heading: Vector2) -> void:
	role = p_role
	color = p_color
	# Seed hue from the base color so the two players start at different hues
	_hue = color.h
	_current_color = color
	heading = p_heading
	if _trail:
		_trail.clear()
	alive = true

func seed_trail() -> void:
	if _trail:
		_trail.append_point(global_position, Time.get_ticks_msec() / 1000.0, _current_color)

func get_trail() -> Trail:
	return _trail

func _physics_process(delta: float) -> void:
	if not alive:
		return

	# Advance hue cycle
	_hue = fmod(_hue + _hue_speed * delta, 1.0)
	_current_color = Color.from_hsv(_hue, 1.0, 1.0)

	queue_redraw()
	_update_trail_width()
	if _trail:
		_trail.update_last_color(_current_color)
	last_position = global_position
	var moved := _handle_input()
	if moved:
		global_position += heading * speed * delta
		if arena_rect.size != Vector2.ZERO:
			global_position.x = clamp(global_position.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
			global_position.y = clamp(global_position.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)
		_trail.append_point(global_position, Time.get_ticks_msec() / 1000.0, _current_color)
	_trail.trim_expired(Time.get_ticks_msec() / 1000.0)


func _handle_input() -> bool:
	var dir := Vector2.ZERO
	if Input.is_action_pressed(input_prefix + "_up"):
		dir.y -= 1.0
	if Input.is_action_pressed(input_prefix + "_down"):
		dir.y += 1.0
	if Input.is_action_pressed(input_prefix + "_left"):
		dir.x -= 1.0
	if Input.is_action_pressed(input_prefix + "_right"):
		dir.x += 1.0
	if dir != Vector2.ZERO:
		heading = dir.normalized()
		return true
	return false

func _draw() -> void:
	draw_circle(Vector2.ZERO, DOT_RADIUS, _current_color)

func eliminate(cause: StringName) -> void:
	if not alive:
		return
	alive = false
	eliminated.emit(cause)
