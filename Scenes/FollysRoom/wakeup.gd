extends CanvasLayer

@export var blackout_screen : ColorRect
@export var wakeup_notice : Control


func close_wakeup() -> void:
	blackout_screen.hide()
	wakeup_notice.hide()

func start_wakeup() -> void:
	Status.woke_up = false
	blackout_screen.show()
	wakeup_notice.show()
	return

func _process(delta: float) -> void:
	if Status.waking_up:
		wakeup_notice.hide()
		blackout_screen.color.a -= delta / 5
		if blackout_screen.color.a <= 0.05:
			blackout_screen.hide()
			Status.waking_up = false

func _input(_event: InputEvent) -> void:
	if not Status.woke_up and Input.is_action_just_pressed("wakeup"):
		Audio.play("alarm_clunk")
		Audio.stop("alarm_sound")
		Audio.play("someplace_calm", null, true)
		Status.woke_up = true
		Status.waking_up = true
