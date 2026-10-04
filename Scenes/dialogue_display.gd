extends CanvasLayer

var active_dialogue : DialogueResource
var current_line : DialogueLine

var next_id : String :
	get:
		if current_line != null:
			return current_line.next_id
		return ""

@onready var dia_label : DialogueLabel = $CL/DlT/DlT/DialogueLabel

func _input(_event: InputEvent) -> void:
	if active_dialogue == null:
		return
	if Input.is_action_just_pressed("advance_dialogue"):
		advance_dialogue()

func load_dialogue(dia:DialogueResource) -> void:
	active_dialogue = dia
	#start_dialogue()
	current_line = await dia.get_next_dialogue_line(Status.current_day_string)
	advance_dialogue(true)
	return


func advance_dialogue(initial:bool=false) -> void:
	if dia_label.is_typing:
		dia_label.skip_typing()
		return
	if not initial:
		current_line = await DialogueManager.get_next_dialogue_line(active_dialogue, next_id)
	if current_line == null:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		active_dialogue = null
		Status.in_dialogue = false
		$CL/You.hide()
		hide()
		return
	dia_label.dialogue_line = current_line
	dia_label.type_out()
	#if current_line.text != "null"
	return

#func display_dialogue_line(dia_line:DialogueLine) -> void:
#	return
