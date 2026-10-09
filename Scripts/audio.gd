extends Node


## The speed, in decibles/s, that a track is faded in/out
const default_fade_in_speed : float = 35.0
const default_fade_out_speed : float = 65.0

var fade_in_tracks : Array = []
var fade_out_tracks : Array = []
var loaded_players : Array = []

var themes : Array[String] = ["prudent_folly", "library", "main_menu", "first_day", "being_followed", "someplace_calm", "hell", "tunneling_through"]

func _process(delta: float) -> void:
	var indices : Array[int] = []
	for track in fade_in_tracks.size():
		fade_in_tracks[track].volume_db = min(fade_in_tracks[track].volume_db + delta*fade_in_tracks[track].fade_in_speed,fade_in_tracks[track].base_volume)
		if fade_in_tracks[track].volume_db >= fade_in_tracks[track].base_volume:
			indices.append(track)
	if indices.size() > 0:
		indices.reverse()
		for index in indices:
			fade_in_tracks.pop_at(index)
	indices = []
	for track in fade_out_tracks.size():
		fade_out_tracks[track].volume_db -= delta*fade_out_tracks[track].fade_out_speed
		if fade_out_tracks[track].volume_db <= -72:
			indices.append(track)
	if indices.size() > 0:
		indices.reverse()
		for index in indices:
			var player = fade_out_tracks.pop_at(index)
			player.stop()
			player.queue_free()

func _get_stream(audio:String) -> AudioStream:
	match(audio):
		"prudent_folly": return preload("res://Assets/Audio/Prudent Folly Upd Air.mp3")
		"book_delivered": return preload("res://Assets/Audio/book_thump.mp3")
		"book_grabbed": return preload("res://Assets/Audio/book_page.mp3")
		"alarm_sound": return preload("res://Assets/Audio/alarmclock_blare.mp3")
		"alarm_clunk": return preload("res://Assets/Audio/alarm_clunk.mp3")
		"food": return preload("res://Assets/Audio/fridge_clink.mp3")
		"dress": return preload("res://Assets/Audio/clothes_dress.mp3")
		"washup": return preload("res://Assets/Audio/wash_up.mp3")
		"library": return preload("res://Assets/Audio/Library.mp3")
		"main_menu": return preload("res://Assets/Audio/Title_Theme.mp3")
		"second_day": return preload("res://Assets/Audio/First_Day_on_the_Job.mp3")
		"first_day": return preload("res://Assets/Audio/First_Day_on_the_Job_with_Librarian.mp3")
		"being_followed": return preload("res://Assets/Audio/i_am_being_followed.mp3")
		"knock": return preload("res://Assets/Audio/knockknock.mp3")
		"someplace_calm": return preload("res://Assets/Audio/Someplace_Calm.mp3")
		"hell": return preload("res://Assets/Audio/Hellscape.mp3")
		"whatdidyoudo": return preload("res://Assets/Audio/whatdidyoudo.mp3")
		"tunneling_through": return preload("res://Assets/Audio/Tunneling_Through.mp3")
		"generator": return preload("res://Assets/Audio/generator.mp3")
		"broken_generator": return preload("res://Assets/Audio/broken_generator.mp3")
	return null

func _get_volume(audio:String) -> float:
	var mod : float = 0.0
	match(audio):
		"prudent_folly": mod = 0.0
		"first_day": mod = 0.0
		"someplace_calm": mod = -10
		"whatdidyoudo": mod = 10
		"generator": mod = 24
	return mod

## AudioStreamPlayers do not have a common inheritance class
func play(audio: String, audio_player = null, fade_in:bool = false, fade_in_speed:float=default_fade_in_speed) -> void:
	var stream = _get_stream(audio)
	if stream == null:
		push_warning("Tried to play non-existant audio track: ", audio)
		return
	print("Playing track: ", audio)
	var next_track : String = ""
	match(audio):
		"prudent_folly","alarm_sound","library","main_menu","first_day","being_followed","someplace_calm","hell","tunneling_through","generator","broken_generator": next_track = audio
	var _volume : float = _get_volume(audio)
	_play_audio(stream, audio, audio_player, _volume, next_track, fade_in, fade_in_speed)
	



signal stop_audio(audio:String)
func stop(audio : String, fade_out:bool = false, fade_out_speed:float=default_fade_out_speed) -> void:
	print("stopping audio: ", audio)
	if fade_out:
		for player in loaded_players:
			if player and player.playing_audio == audio and not fade_out_tracks.has(player):
				player.fade_out_speed = fade_out_speed
				fade_out_tracks.append(player)
		return
	stop_audio.emit(audio)

func stop_themes() -> void:
	print("Stopping all themes")
	for track in themes:
		stop(track, true)

func _play_audio(audio : AudioStream, audio_name:String, forced_player=null, _volume:float=0.0, next_track:String="", fade_in:bool=false, fade_in_speed:float=default_fade_in_speed) -> void:
	var audio_player
	if forced_player != null:
		audio_player = forced_player
	else:
		audio_player = AudioPlayer.new()
		add_child(audio_player)
		audio_player.finished.connect(audio_player.queue_free)
	audio_player.playing_audio = audio_name
	if not stop_audio.is_connected(audio_player.end_play):
		stop_audio.connect(audio_player.end_play)
	if next_track != "" and not audio_player.finished.is_connected(_loop_audio):
		audio_player.finished.connect(_loop_audio.bind(next_track, forced_player))
	audio_player.stream = audio
	audio_player.volume_db = _volume
	audio_player.base_volume = _volume
	audio_player.play()
	if fade_in:
		audio_player.fade_in_speed = fade_in_speed
		audio_player.volume_db = -50 + _volume
		fade_in_tracks.append(audio_player)
	loaded_players.append(audio_player)

func _loop_audio(audio : String, forced_player=null) -> void:
	# insert 'if' conditionals to check if playing the track is appropriate ~ i.e. change to a new track for certain theme loops
	play(audio, forced_player)
	return
