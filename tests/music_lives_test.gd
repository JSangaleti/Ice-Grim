extends Node
var game
var checks := 0
var failed := false
var finishes := 0

func _ready() -> void:
	await frames(2)
	game.menu()
	var audio = game.audio
	audio.stop_all()
	audio.silent_for_tests = false
	audio.music.finished.connect(func(): finishes += 1)
	var first: String = audio.track_path(0)
	var second: String = audio.track_path(2)
	var third: String = audio.track_path(5)
	var original = load(first)
	var original_loop: bool = original.loop
	audio.track(0)
	await wall_wait(120)
	check(audio.current == first and audio.music.playing and not audio.music.stream.loop, "music starts without a built-in loop")
	check(original.loop == original_loop and audio.music.stream != original, "cached source is not modified")
	var position: float = audio.music.get_playback_position()
	audio.track(2)
	audio.track(5)
	check(audio.current == first and audio.pending == third and audio.requested == third, "scene changes queue only the latest requested track")
	check(audio.music.get_playback_position() >= position - 0.03, "changing scene does not restart or cut the playing track")
	audio.track(5)
	check(audio.current == first and audio.pending == third, "repeated requests do not interrupt playback")
	await finish_song(audio)
	check(audio.current == third and audio.music.playing and audio.pending.is_empty(), "next song starts only after native finished signal")
	audio.track(0)
	audio.track(5)
	check(audio.pending.is_empty(), "returning to the current song cancels an obsolete queued switch")
	await finish_song(audio)
	check(audio.current == third and audio.music.playing, "same scene repeats the complete song after its end")
	audio.track(2)
	await finish_song(audio)
	check(audio.current == second and audio.music.playing, "second queued transition also waits for completion")
	game.menu()
	check(audio.current == second and audio.pending == first, "return to menu also leaves the current song playing to its end")
	audio.stop_all()
	await wall_wait(100)
	check(not audio.music.playing and audio.current.is_empty() and audio.pending.is_empty() and audio.requested.is_empty(), "explicit shutdown stops playback and clears queued requests")
	audio.silent_for_tests = true
	game.start_run(false)
	await frames(75)
	game.load_level(6)
	game.resume()
	await frames(3)
	var world = game.world
	var p = world.player
	check(not world.arena_locked and world.player_lives == 3 and not game.lives_label.visible, "boss bonus is not displayed or usable during approach")
	p.die("approach hazard")
	check(game.state == game.Screen.DEAD, "approach retains the one-hit campaign rule")
	game.retry()
	await frames(3)
	check(game.level == 1, "approach Game Over restarts campaign")
	game.load_level(6)
	game.resume()
	await frames(3)
	world = game.world
	p = world.player
	p.axis_override = 0
	p.position = Vector2(world.ARENA_START + 100, 484)
	await frames(3)
	check(world.arena_locked and world.boss.active and world.player_lives == 3, "entering arena starts three lives")
	check(game.lives_label.visible and "3 / 3" in game.lives_label.text, "HUD displays player lives separately from boss health")
	var boss = world.boss
	boss.hp = 6
	boss.cycle = 0.1
	boss.fired = {"aim0":true,"aim1":true,"aim2":true,"aim3":true,"aim4":true,"wave":true,"rain":true,"beam":true}
	var attempts: int = game.attempts
	p.position = boss.position + Vector2(-60, 60)
	await frames(4)
	check(world.player_lives == 2 and not p.dead and game.state == game.Screen.PLAYING and "2 / 3" in game.lives_label.text, "closed boss contact consumes first life instead of ending campaign")
	check(boss.hp == 6 and game.level == 6 and game.attempts == attempts, "boss progress and campaign attempt survive life loss")
	check(p.position.distance_to(Vector2(world.ARENA_START + 590, 402)) < 6 and p.damage_protection > 1.3, "life loss returns player to safe platform with brief protection")
	for i in 2:
		spawn_beam(world, p.position - Vector2(0, 20))
	await frames(6)
	check(world.player_lives == 2, "multiple overlapping attacks cannot drain lives during recovery")
	var protection: float = p.damage_protection
	var pos: Vector2 = p.position
	game.pause()
	await frames(12)
	check(p.damage_protection == protection and p.position == pos, "pause freezes recovery protection and position")
	game.resume()
	await frames(100)
	boss.cycle = 0.1
	p.position = boss.position + Vector2(-60, 60)
	await frames(4)
	check(world.player_lives == 1 and not p.dead and boss.hp == 6 and "1 / 3" in game.lives_label.text, "second hit leaves one life and preserves boss health")
	await frames(100)
	spawn_beam(world, p.position - Vector2(0, 20))
	await frames(5)
	check(world.player_lives == 0 and p.dead and game.state == game.Screen.DEAD, "third hit produces Game Over")
	game.retry()
	await frames(3)
	check(game.level == 1, "exhausted boss lives return to phase one on retry")
	game.load_level(6)
	game.resume()
	await frames(3)
	check(game.world.player_lives == 3 and not game.world.arena_locked and game.world.player.damage_protection == 0, "fresh boss stage restores lives and clears recovery state")
	if not failed:
		print("MUSIC_LIVES_TEST_OK: %d checks; real MP3 completion/queue/cancellation/repetition and three-life arena damage/recovery/Game Over" % checks)
		game.quit(0)

func spawn_beam(world, pos: Vector2) -> void:
	var shot = load("res://gd/boss_projectile.gd").new()
	shot.kind = shot.Kind.BEAM
	shot.position = pos
	shot.world = world
	world.add_child(shot)

func finish_song(audio) -> void:
	var before := finishes
	var length: float = audio.music.stream.get_length()
	check(length > 0.1, "native stream has a valid duration")
	# Seek in tests only, so real MP3 completion can be checked without minutes of waiting.
	audio.music.seek(maxf(0, length - 0.08))
	var deadline := Time.get_ticks_msec() + 3000
	while finishes == before and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		OS.delay_msec(2)
	check(finishes == before + 1, "native audio finished emitted once")

func wall_wait(milliseconds: int) -> void:
	var deadline := Time.get_ticks_msec() + milliseconds
	while Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		OS.delay_msec(2)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func check(condition: bool, label: String) -> void:
	if failed:
		return
	if not condition:
		failed = true
		push_error("MUSIC_LIVES_TEST_FAILED: " + label)
		get_tree().quit(1)
		return
	checks += 1
	print("PASS MUSIC_LIVES %02d %s" % [checks, label])
