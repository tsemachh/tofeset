extends Control

@onready var _score_label: Label = $ScoreLabel
@onready var _role_label: Label = $RoleLabel
@onready var _countdown_label: Label = $CountdownLabel

func update_score(p1: int, p2: int) -> void:
	_score_label.text = "P1: %d  —  P2: %d" % [p1, p2]

func set_roles(p1_role: Player.Role, p2_role: Player.Role) -> void:
	var r1 := "CHASER" if p1_role == Player.Role.CHASER else "RUNNER"
	var r2 := "CHASER" if p2_role == Player.Role.CHASER else "RUNNER"
	_role_label.text = "P1: %s    P2: %s" % [r1, r2]

func set_countdown(val: String) -> void:
	_countdown_label.text = val

func show_countdown(visible: bool) -> void:
	_countdown_label.visible = visible
