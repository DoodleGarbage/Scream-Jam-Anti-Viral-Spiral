extends Node

#var audio_player

#func _ready() -> void:
#	play("prudent_folly")

var fade_in_tracks : Array = []

func _process(delta: float) -> void:
	var indices : Array[int] = []
	for track in fade_in_tracks.size():
		fade_in_tracks[track].volume_db = min(fade_in_tracks[track].volume_db + delta*10.0,fade_in_tracks[track].base_volume)
		if fade_in_tracks[track].volume_db >= fade_in_tracks[track].base_volume:
			indices.append(track)
	if indices.size() > 0:
		indices.reverse()
		for index in indices:
			fade_in_tracks.pop_at(index)

func _get_stream(audio:String) -> AudioStream:
	match(audio):
		"prudent_folly": return preload("res://Assets/Audio/Prudent Folly.mp3")
		"book_delivered": return preload("res://Assets/Audio/book_thump.mp3")
		"book_grabbed": return preload("res://Assets/Audio/book_page.mp3")
		"alarm_sound": return preload("res://Assets/Audio/alarmclock_blare.mp3")
		"alarm_clunk": return preload("res://Assets/Audio/alarm_clunk.mp3")
		"food": return preload("res://Assets/Audio/fridge_clink.mp3")
		"dress": return preload("res://Assets/Audio/clothes_dress.mp3")
		"washup": return preload("res://Assets/Audio/wash_up.mp3")
	return null

func _get_volume(audio:String) -> float:
	match(audio):
		"prudent_folly": return -10.0
	return 0.0

## AudioStreamPlayers do not have a common inheritance class
func play(audio: String, audio_player = null, fade_in:bool = false) -> void:
	var stream = _get_stream(audio)
	if stream == null:
		push_warning("Tried to play non-existant audio track ", audio)
		return
	var next_track : String = ""
	match(audio):
		"prudent_folly": next_track = "prudent_folly"
		"alarm_sound": next_track = "alarm_sound"
	var volume : float = _get_volume(audio)
	_play_audio(stream, audio, audio_player, volume, next_track, fade_in)



signal stop_audio(audio:String)
func stop(audio : String) -> void:
	print("stopping audio: ", audio)
	stop_audio.emit(audio)

func _play_audio(audio : AudioStream, audio_name:String, forced_player=null, volume:float=0.0, next_track:String="", fade_in:bool=false) -> void:
	var audio_player
	if forced_player != null:
		audio_player = forced_player
	else:
		audio_player = AudioPlayer.new()
		add_child(audio_player)
	audio_player.playing_audio = audio_name
	stop_audio.connect(audio_player.end_play)
	if next_track != "":
		audio_player.finished.connect(_loop_audio.bind(next_track))
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.stream = audio
	audio_player.volume_db = volume
	audio_player.base_volume = volume
	audio_player.play()
	if fade_in:
		audio_player.volume_db = -50 + volume
		fade_in_tracks.append(audio_player)

func _loop_audio(audio : String) -> void:
	# insert 'if' conditionals to check if playing the track is appropriate ~ i.e. change to a new track for certain theme loops
	play(audio)
	return
