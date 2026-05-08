extends Node

const MIX_RATE := 22050
const BUFFER_SIZE := 1024
const BPM_MIN := 80.0
const BPM_MAX := 240.0

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _active := false
var _current_bpm := BPM_MIN
var _phase := 0.0
var _note_phase := 0.0  # position within current note period (0..1)
var _fade_out := false
var _fade_volume := 1.0

func _ready() -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = float(BUFFER_SIZE) / float(MIX_RATE)
	_player = AudioStreamPlayer.new()
	_player.stream = stream
	_player.volume_db = -6.0
	add_child(_player)

func start_round() -> void:
	_active = true
	_fade_out = false
	_fade_volume = 1.0
	_phase = 0.0
	_note_phase = 0.0
	_player.play()
	_playback = _player.get_stream_playback()

func stop_round() -> void:
	_fade_out = true

func set_distance(d: float, d_min: float, d_max: float) -> void:
	if d_max <= d_min:
		_current_bpm = BPM_MAX
		return
	var t := clampf((d - d_min) / (d_max - d_min), 0.0, 1.0)
	_current_bpm = lerpf(BPM_MAX, BPM_MIN, t)

func distance_to_bpm(d: float, d_min: float, d_max: float) -> float:
	if d_max <= d_min:
		return BPM_MAX
	var t := clampf((d - d_min) / (d_max - d_min), 0.0, 1.0)
	return lerpf(BPM_MAX, BPM_MIN, t)

func _process(_delta: float) -> void:
	if not _active or _playback == null:
		return

	if _fade_out:
		_fade_volume = move_toward(_fade_volume, 0.0, _delta * 2.0)
		if _fade_volume <= 0.0:
			_active = false
			_player.stop()
			return

	var frames_available := _playback.get_frames_available()
	if frames_available <= 0:
		return

	var note_period_frames := int(MIX_RATE * 60.0 / _current_bpm)
	var buf := PackedVector2Array()
	buf.resize(frames_available)

	for i in frames_available:
		_note_phase += 1.0
		if _note_phase >= note_period_frames:
			_note_phase = 0.0
		# Square wave: first half of note period = high, second = low
		var half := note_period_frames / 2
		var sample := 0.3 if _note_phase < half else -0.3
		sample *= _fade_volume
		buf[i] = Vector2(sample, sample)

	_playback.push_buffer(buf)
