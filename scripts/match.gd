class_name Match extends Node2D

enum State { TITLE, COUNTDOWN, PLAYING, ROUND_END, MATCH_END }

const WINS_NEEDED := 3
const ROUND_END_FREEZE := 1.5
const COUNTDOWN_DURATION := 1.0
const ARENA_MARGIN := 40.0 + 60.0

var state: State = State.TITLE
var score := { "p1": 0, "p2": 0 }
var round_index := 0
var _winner_key := ""
var _round_cause := &""
var _freeze_timer := 0.0
var _countdown_value := 3
var _countdown_timer := 0.0

var _players: Array = []
var _arena: Arena
var _hud: Control
var _title_screen: Control
var _round_end_overlay: Control
var _match_end_screen: Control

# Spawn positions (set after arena is ready)
var _spawn_p1 := Vector2.ZERO
var _spawn_p2 := Vector2.ZERO

func _ready() -> void:
	_arena = $Arena
	_hud = $UI/HUD
	_title_screen = $UI/TitleScreen
	_round_end_overlay = $UI/RoundEndOverlay
	_match_end_screen = $UI/MatchEndScreen

	CollisionService.set_arena(_arena)

	_players.append($Player1)
	_players.append($Player2)

	for p in _players:
		p.init_trail(self)
		p.eliminated.connect(_on_player_eliminated.bind(p))

	_set_state(State.TITLE)

func _set_state(new_state: State) -> void:
	state = new_state
	_hud.visible = (state == State.PLAYING or state == State.COUNTDOWN)
	_title_screen.visible = (state == State.TITLE)
	_round_end_overlay.visible = (state == State.ROUND_END)
	_match_end_screen.visible = (state == State.MATCH_END)

	match state:
		State.TITLE:
			AudioEngine.stop_round()
		State.COUNTDOWN:
			_countdown_value = 3
			_countdown_timer = 0.0
			_hud.set_countdown(str(_countdown_value))
			_hud.show_countdown(true)
		State.PLAYING:
			_hud.show_countdown(false)
			AudioEngine.start_round()
		State.ROUND_END:
			AudioEngine.stop_round()
			_freeze_timer = 0.0
			var winner_label := "Player 1" if _winner_key == "p1" else "Player 2"
			_round_end_overlay.set_result(winner_label, _round_cause)
		State.MATCH_END:
			AudioEngine.stop_round()
			var match_winner := "Player 1" if score["p1"] >= WINS_NEEDED else "Player 2"
			_match_end_screen.set_result(match_winner, score["p1"], score["p2"])

func _process(delta: float) -> void:
	match state:
		State.TITLE:
			if Input.is_action_just_pressed("ui_accept"):
				_start_match()
		State.COUNTDOWN:
			_countdown_timer += delta
			if _countdown_timer >= COUNTDOWN_DURATION:
				_countdown_timer = 0.0
				_countdown_value -= 1
				if _countdown_value <= 0:
					_set_state(State.PLAYING)
				else:
					_hud.set_countdown(str(_countdown_value))
		State.PLAYING:
			CollisionService.check(_players)
			var d: float = _players[0].global_position.distance_to(_players[1].global_position)
			var d_max: float = _arena.rect.size.length()
			AudioEngine.set_distance(d, 0.0, d_max)
			_hud.update_score(score["p1"], score["p2"])
		State.ROUND_END:
			_freeze_timer += delta
			if _freeze_timer >= ROUND_END_FREEZE:
				_advance_round()
		State.MATCH_END:
			if Input.is_action_just_pressed("ui_accept"):
				_start_match()
			if Input.is_action_just_pressed("ui_cancel"):
				get_tree().quit()

func _start_match() -> void:
	score = { "p1": 0, "p2": 0 }
	round_index = 0
	_start_round()

func _start_round() -> void:
	var vp := get_viewport_rect()
	var cx := vp.size.x / 2.0
	var cy := vp.size.y / 2.0
	_spawn_p1 = Vector2(cx - 300.0, cy)
	_spawn_p2 = Vector2(cx + 300.0, cy)

	var p1: Player = _players[0]
	var p2: Player = _players[1]

	# Alternate who starts as chaser each round
	if round_index % 2 == 0:
		p1.setup(Player.Role.CHASER, Color.CYAN, Vector2.RIGHT)
		p2.setup(Player.Role.RUNNER, Color.MAGENTA, Vector2.LEFT)
	else:
		p1.setup(Player.Role.RUNNER, Color.CYAN, Vector2.RIGHT)
		p2.setup(Player.Role.CHASER, Color.MAGENTA, Vector2.LEFT)
	# Give players slightly different hue speeds so their colors diverge
	p1._hue_speed = 0.55
	p2._hue_speed = 0.73

	p1.arena_rect = _arena.rect
	p2.arena_rect = _arena.rect

	p1.global_position = _spawn_p1
	p1.last_position = _spawn_p1
	p2.global_position = _spawn_p2
	p2.last_position = _spawn_p2

	# Seed trail at correct spawn position (must be after global_position is set)
	p1.seed_trail()
	p2.seed_trail()

	_hud.set_roles(p1.role, p2.role)
	_hud.update_score(score["p1"], score["p2"])
	_set_state(State.COUNTDOWN)

func _on_player_eliminated(cause: StringName, player: Player) -> void:
	if state != State.PLAYING:
		return
	var loser_key := "p1" if player == _players[0] else "p2"
	var winner_key := "p2" if loser_key == "p1" else "p1"
	_end_round(winner_key, cause)

func _end_round(winner_key: String, cause: StringName) -> void:
	score[winner_key] += 1
	_winner_key = winner_key
	_round_cause = cause
	round_index += 1
	_set_state(State.ROUND_END)

func _advance_round() -> void:
	if score["p1"] >= WINS_NEEDED or score["p2"] >= WINS_NEEDED:
		_set_state(State.MATCH_END)
	else:
		_start_round()
