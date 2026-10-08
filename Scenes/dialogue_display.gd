extends CanvasLayer

var active_dialogue : DialogueResource
var current_line : DialogueLine

var skipping_allowed : bool = false

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
	print("Skipping. Skipping status: ", skipping_allowed)
	if not skipping_allowed:
		return
	if dia_label.is_typing:
		dia_label.skip_typing()
		skipping_allowed = false
		$SkipInterrupt.start()
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
	$SkipInterrupt.start()
	skipping_allowed = false
	print("skipping? ", skipping_allowed)

func end_dialogue() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	active_dialogue = null
	Status.in_dialogue = false
	Status.allow_dialogue = false
	$DialogueInterrupt.start()
	$CL/You.hide()
	hide()
	return


func _on_interrupt_timeout() -> void:
	Status.allow_dialogue = true


func _on_skip_interrupt_timeout() -> void:
	skipping_allowed = true
