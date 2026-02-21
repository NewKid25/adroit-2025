extends Node2D

@onready
var oy := position.y

@onready
var r := randf_range(0, 40)

func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	position.y = oy + 6 + sin(t * 0.4 + r) * 6
