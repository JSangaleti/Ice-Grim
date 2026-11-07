extends Node
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var next := 0
var current := ""
var requested := ""
var pending := ""
var stopping := false
var muted := false
var silent_for_tests := false

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	music.finished.connect(_on_music_finished)
	add_child(music)
	for i in 8:
		var effect := AudioStreamPlayer.new()
		effect.bus = "SFX"
		add_child(effect)
		effects.append(effect)

const AUTHOR_SLOTS := ["menu", "fases_1_2", "fases_3_4", "fase_5", "boss"]

func author_path(slot: String) -> String:
	for extension in ["ogg", "mp3"]:
		var path := "res://assets/music/juliano/%s.%s" % [slot, extension]
		if ResourceLoader.exists(path):
			return path
	return ""

func author_tracks_complete() -> bool:
	for slot in AUTHOR_SLOTS:
		if author_path(slot).is_empty():
			return false
	return true

func track_path(level: int) -> String:
	var slot: String = AUTHOR_SLOTS[0 if level == 0 else (1 if level <= 2 else (2 if level <= 4 else (3 if level == 5 else 4)))]
	var author := author_path(slot)
	if not author.is_empty():
		return author
	var file := "musica1.mp3" if level < 2 else ("musica2.mp3" if level < 4 else "musica3-parte1.mp3")
	return "res://assets/music/" + file

func track(level: int) -> void:
	if silent_for_tests:
		return
	requested = track_path(level)
	pending = requested if requested != current else ""
	# A scene change only changes the next selection. Never cut a playing song.
	if current.is_empty():
		_play_track(requested)

func _play_track(path: String) -> void:
	stopping = false
	current = path
	pending = ""
	# Use a private stream: disabling the built-in loop must not edit the resource.
	var stream = load(path).duplicate()
	stream.loop = false
	music.stream = stream
	music.play()

func _on_music_finished() -> void:
	if stopping or silent_for_tests or current.is_empty():
		return
	# The latest requested scene wins; obsolete intermediate requests are discarded.
	_play_track(requested if not requested.is_empty() else current)

func sfx(id: String) -> void:
	if silent_for_tests:
		return
	var effect: AudioStreamPlayer = effects[next % effects.size()]
	next += 1
	effect.stream = load("res://assets/sfx/%s.wav" % id)
	effect.play()

func stop_all() -> void:
	stopping = true
	current = ""
	requested = ""
	pending = ""
	music.stop()
	music.stream = null
	for effect in effects:
		effect.stop()
		effect.stream = null

func _exit_tree() -> void:
	stop_all()

func set_volume(m: float, s: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(maxf(m, 0.0001)) - 8)
	AudioServer.set_bus_volume_db(2, linear_to_db(maxf(s, 0.0001)) - 4)

func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)
