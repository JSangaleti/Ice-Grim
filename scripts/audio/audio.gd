class_name AudioService
extends IAudioService

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)


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

	_music_player.stream = music
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()
