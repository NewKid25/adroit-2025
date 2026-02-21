extends Control

var time = 0.0

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	visible = true
	time += delta * 2
	var s = sin(time + 0.8)
	scale = Vector2(s, s)
	rotation = time * 0.1 - 0.03
	if s <= 0:
		queue_free()
