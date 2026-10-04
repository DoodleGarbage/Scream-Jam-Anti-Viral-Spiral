extends Node

#var audio_player

#func _ready() -> void:
#	play("prudent_folly")

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

## AudioStreamPlayers do not have a common inheritance class
func play(audio: String, audio_player = null) -> void:
	var stream = _get_stream(audio)
	if stream == null:
		push_warning("Tried to play non-existant audio track ", audio)
		return
	var next_track : String = ""
	match(audio):
		"prudent_folly": next_track = "prudent_folly"
		"alarm_sound": next_track = "alarm_sound"
	_play_audio(stream, audio, audio_player, next_track)



signal stop_audio(audio:String)
func stop(audio : String) -> void:
	print("stopping audio: ", audio)
	stop_audio.emit(audio)

func _play_audio(audio : AudioStream, audio_name:String, forced_player=null, next_track:String="") -> void:
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
	audio_player.play()

func _loop_audio(audio : String) -> void:
	# insert 'if' conditionals to check if playing the track is appropriate ~ i.e. change to a new track for certain theme loops
	play(audio)
	return
