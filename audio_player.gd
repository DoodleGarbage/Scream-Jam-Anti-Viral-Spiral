extends AudioStreamPlayer
class_name AudioPlayer

var playing_audio : String = ""

func end_play(audio:String) -> void:
	if audio == playing_audio:
		stop()
