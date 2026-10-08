extends AudioStreamPlayer
class_name AudioPlayer

var playing_audio : String = ""
var base_volume : float = 0.0
var fade_in_speed : float = 0.0
var fade_out_speed : float = 0.0

func end_play(audio:String) -> void:
	if audio == playing_audio:
		stop()
		queue_free()
