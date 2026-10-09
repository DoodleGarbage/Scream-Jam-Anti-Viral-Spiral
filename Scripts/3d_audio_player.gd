extends AudioStreamPlayer3D
class_name AudioPlayer3D

var playing_audio : String = ""
var base_volume : float = 0.0
var fade_in_speed : float = 0.0
var fade_out_speed : float = 0.0

var disabled : bool = false

func end_play(audio:String) -> void:
	if audio == playing_audio:
		stop()
		queue_free()
