extends Node

var _music_player: AudioStreamPlayer
var _current_music_id: String = ""


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)


func play_music(music_id: String) -> void:
	var path: String
	match music_id:
		"musica1":
			path = "res://assets/music/musica1.mp3"
		"musica2":
			path = "res://assets/music/musica2.mp3"
		_:
			push_warning("Música desconhecida: %s" % music_id)
			return

	var music := load(path) as AudioStream
	if music == null:
		push_error("Não foi possível carregar a música: %s" % path)
		return

	_current_music_id = music_id
	_music_player.stream = music
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func _on_music_finished() -> void:
	match _current_music_id:
		"musica1":
			play_music("musica2")
		"musica2":
			play_music("musica1")
