extends Control

var time = 0.0
var rot_dir = 0.0

func _ready() -> void:
	visible = false

	# rot_dir = randf_range(0.5, 1.5)
	# if randi_range():
	# 	rot_dir *= -1


func _process(delta: float) -> void:
	visible = true
	time += delta * 2
	var s = sin(time + 0.8)
	scale = Vector2(s, s)
	rotation = time * 0.1 - 0.03  * rot_dir
	if s <= 0:
		queue_free()
