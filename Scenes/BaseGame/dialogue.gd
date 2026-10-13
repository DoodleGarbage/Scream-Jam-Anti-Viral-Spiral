extends Node

#var loaded_dialogue : Dialogue

signal dialogue_finished()

var dialogue_display : CanvasLayer :
	get:
		return Status.game_node.dialogue_display


func _load_dialogue(dia:DialogueResource) -> void:
	dialogue_display.load_dialogue(dia)
	return

func trigger_event(event:String, dialogue:DialogueResource) -> void:
	#print("Dialogue event ", event, " triggered!")
	Status.in_dialogue = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialogue_display.show()
	_load_dialogue(dialogue)
	match(event):
		"washup":
			dialogue_display.get_node("CL/You").show()
	return


func finish_dialogue() -> void:
	dialogue_finished.emit()
