extends CanvasLayer


## Portraits
## Day 1
const folly_1 := preload("res://Assets/Textures/Characters/FollyPortraits/calmfolly.png")
## Day 2
const folly_2 := preload("res://Assets/Textures/Characters/FollyPortraits/day2follyEffects.png")
## Day 3
const folly_3 := preload("res://Assets/Textures/Characters/FollyPortraits/day3FollyEffects.png")
## Hell
const folly_4 := preload("res://Assets/Textures/Characters/FollyPortraits/hellfollyEffects.png")
## Recovery
const folly_5 := preload("res://Assets/Textures/Characters/FollyPortraits/recoveryfollyEffects.png")

## Day 2, dialogue
const folly_2_nofx := preload("res://Assets/Textures/Characters/FollyPortraits/day2folly.png")
## Day 3, dialogue
const folly_3_nofx := preload("res://Assets/Textures/Characters/FollyPortraits/day3folly.png")
## Hell, dialogue
const folly_4_nofx := preload("res://Assets/Textures/Characters/FollyPortraits/hellfolly.png")


const raincoat := preload("res://Assets/Textures/Characters/raincoatportrait.png")
const raincoat_normal := preload("res://Assets/Textures/Characters/raincoatnormalportrait.png")
const raincoat_evil := preload("res://Assets/Textures/Characters/raincoatevilportrait.png")
const librarian := preload("res://Assets/Textures/Characters/librarianportrait.png")
const brawny := preload("res://Assets/Textures/Characters/brawnyportrait.png")
const hermit := preload("res://Assets/Textures/Characters/hermitportrait.png")
const hermit_alt := preload("res://Assets/Textures/Characters/althermitportrait.png")


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

func load_dialogue(dia:DialogueResource, cue:String="") -> void:
	active_dialogue = dia
	start_dialogue(cue)
	#advance_dialogue()
	return

func start_dialogue(cue:String="") -> void:
	Status.in_dialogue = true
	current_line = await DialogueManager.get_next_dialogue_line(active_dialogue, cue)
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
	$CL/Chara.hide()
	dia_label.dialogue_line = current_line
	$CL/Name/NameLabel.text = current_line.character
	match(current_line.character):
		"Folly":
			var tag : String = current_line.get_tag_value("emotion")
			if tag == "":
				tag = Status.current_day_string
			$CL/Chara.show()
			match(tag):
				"calm", "day1", "night1":
					$CL/Chara.texture = folly_1
				"day2", "night2", "childhood":
					$CL/Chara.texture = folly_2_nofx
				"day3", "night3", "tunnels":
					$CL/Chara.texture = folly_3_nofx
				"hell", "hellnight", "crash":
					$CL/Chara.texture = folly_4_nofx
				"recovery", "recoverynight":
					$CL/Chara.texture = folly_5
				_: 
					$CL/Chara.hide() ## Hide the image if no match found
		"Raincoat":
			$CL/Chara.show()
			match(current_line.get_tag_value("emotion")):
				"normal": $CL/Chara.texture = raincoat_normal
				"evil": $CL/Chara.texture = raincoat_evil
				_: $CL/Chara.texture = raincoat
		"Librarian":
			$CL/Chara.show()
			$CL/Chara.texture = librarian
		"Brawny":
			$CL/Chara.show()
			$CL/Chara.texture = brawny
		"Hermit":
			if current_line.get_tag_value("emotion") != "":
				$CL/Chara.show()
				match(current_line.get_tag_value("emotion")):
					"no": $CL/Chara.texture = hermit
					_: $CL/Chara.texture = hermit_alt
	
	var mirror_tag : String = current_line.get_tag_value("mirror")
	if mirror_tag == "day":
		mirror_tag = Status.current_day_string
	
	## Hide the chara if we're looking at the mirror
	if mirror_tag != "":
		$CL/Chara.hide()
	
	$CL/You.show()
	match(mirror_tag):
		"day1","night1":
			$CL/You.texture = folly_1
		"day2","night2":
			$CL/You.texture = folly_2
		"day3","night3":
			$CL/You.texture = folly_3
		"hell","hellnight":
			$CL/You.texture = folly_4
		"recovery","recoverynight":
			$CL/You.texture = folly_5
		_: $CL/You.hide()
	
	dia_label.type_out()
	$SkipInterrupt.start()
	skipping_allowed = false
	#print("skipping? ", skipping_allowed)

func end_dialogue(bypass_allow:bool = false) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	active_dialogue = null
	Status.in_dialogue = false
	Status.allow_dialogue = bypass_allow
	$DialogueInterrupt.start()
	$CL/You.hide()
	hide()
	Dialogue.finish_dialogue()
	return


func _on_interrupt_timeout() -> void:
	Status.allow_dialogue = true


func _on_skip_interrupt_timeout() -> void:
	skipping_allowed = true
