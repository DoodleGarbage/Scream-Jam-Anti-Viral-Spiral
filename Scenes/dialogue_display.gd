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
	start_dialogue()
	#advance_dialogue()
	return

func start_dialogue() -> void:
	Status.in_dialogue = true
	current_line = await DialogueManager.get_next_dialogue_line(active_dialogue, Status.current_day_string)
	if current_line == null:
		end_dialogue()
		return
	#if current_line.character:
		#current_line = await DialogueManager.get_next_dialogue_line(active_dialogue, current_line.next_id)
	display_dialogue()

func advance_dialogue() -> void:
	if dia_label.is_typing:
		#dia_label.skip_typing()EE
		return
	#if not initial:
	current_line = await DialogueManager.get_next_dialogue_line(active_dialogue, next_id)
	if current_line == null:
		end_dialogue()
		return
	display_dialogue()
	return

func display_dialogue() -> void:
	dia_label.dialogue_line = current_line
	$CL/Name/NameLabel.text = current_line.character
	dia_label.type_out()

func end_dialogue() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	active_dialogue = null
	Status.in_dialogue = false
	$CL/You.hide()
	hide()
	return
