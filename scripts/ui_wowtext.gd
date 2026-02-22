extends Control

var time = 0.0
var rot_dir = 0.0

@export var sound_effect:AudioStream

func _ready() -> void:
	SfxManager.play_sound(sound_effect)

	visible = false

	rot_dir = randf_range(0.5, 2.0)
	if randi_range(0, 1):
		rot_dir *= -1


func _process(delta: float) -> void:
	visible = true
	time += delta * 2
	var s = sin(time + 0.8)
	scale = Vector2(s, s)
	rotation += delta * 0.1 * rot_dir
	if s <= 0:
		queue_free()
