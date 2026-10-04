extends Node

var loaded_dialogue : Dialogue

var dialogue_display : CanvasLayer :
	get:
		return Status.game_node.dialogue_display


func _load_dialogue(dia:Dialogue) -> void:
	return

func trigger_event(event:String) -> void:
	Status.in_dialogue = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialogue_display.show()
	match(event):
		"washup":
			dialogue_display.get_node("CL/You").show()
	return
