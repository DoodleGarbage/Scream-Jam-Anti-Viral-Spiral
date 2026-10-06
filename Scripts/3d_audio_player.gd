extends AudioStreamPlayer3D
class_name AudioPlayer3D

var playing_audio : String = ""
var base_volume : float = 0.0

func end_play(audio:String) -> void:
	if audio == playing_audio:
		stop()
