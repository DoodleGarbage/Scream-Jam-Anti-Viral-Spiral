extends Node

#var loaded_dialogue : Dialogue

signal dialogue_finished()

var dialogue_display : CanvasLayer :
	get:
		return Status.game_node.dialogue_display


func _load_dialogue(dia:DialogueResource, cue:String="") -> void:
	var used_cue : String = Status.current_day_string
	if cue != "":
		used_cue = cue
	dialogue_display.load_dialogue(dia, used_cue)
	return

func trigger_event(event:String, dialogue:DialogueResource, forced_cue:String="") -> void:
	#print("Dialogue event ", event, " triggered!")
	Status.in_dialogue = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialogue_display.show()
	_load_dialogue(dialogue, forced_cue)
	#match(event):
		#"washup":
			#dialogue_display.get_node("CL/You").show()
	return


func finish_dialogue() -> void:
	dialogue_finished.emit()
