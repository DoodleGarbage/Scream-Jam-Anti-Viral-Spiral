extends AudioStreamPlayer3D
class_name AudioPlayer3D

var playing_audio : String = ""

func end_play(audio:String) -> void:
	if audio == playing_audio:
		stop()
