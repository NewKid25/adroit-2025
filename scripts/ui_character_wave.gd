extends Node2D

@onready
var oy := position.y

@onready
var r := randf_range(0, 40)

func _process(delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	position.y = lerp(position.y, oy + 6 + sin(t * 0.4 + r) * 6, delta * 2)
