extends OmniLight3D

## How often, in %, the light flickers
@export var flicker_chance : float = 0.5
## How long, in seconds, between flickers.
@export var flicker_timer : float = 5.0
## How much, in seconds, that the flicker chance timer can vary in +/-
@export var flicker_variance : float = 2.0
## How much time in between flicks
@export var flick_duration : float = 0.1
@export var flick_duration_variance : float = 0.05
@export var flick_count : int = 3
@export var flick_count_variance : int = 2

var flicker_state : bool = false
var _flick_timing : float = 0.0
#var _flick_timing_variance : float = 0.0
var _flick_quantity : int = 0
var _flick_count_variance : int = 0

var _flicker_timing : float = 0.0
var _flicker_variant : float = 0.0

func _ready() -> void:
	_flicker_variant = randf_range(-flicker_variance, flicker_variance)
	return

func _process(delta: float) -> void:
	_flicker_timing += delta
	if flicker_state:
		if _flick_quantity >= flick_count + _flick_count_variance:
			visible = true
			flicker_state = false
			_flicker_timing = 0.0
			return
		if _flicker_timing >= _flick_timing:
			_flicker_timing = 0.0
			visible = !visible
			_flick_quantity += 1
			_flick_timing = flick_duration + randf_range(-flick_duration_variance, flick_duration_variance)
			return
		return
	if _flicker_timing < flicker_timer + _flicker_variant:
		return
	_flicker_timing = 0.0
	_flicker_variant = randf_range(-flicker_variance, flicker_variance)
	var rng : float = randf()
	if rng < flicker_chance:
		_flick_count_variance = randi_range(-flick_count_variance, flick_count_variance)
		_flick_timing = flick_duration + randf_range(-flick_duration_variance, flick_duration_variance)
		_flick_quantity = 0
		flicker_state = true
		visible = false
