extends Sprite2D

@export
var inverted := false
@export
var speed_mod := 1.0

func _process(delta: float) -> void:
	rotation += delta * 0.07 * (-1 if inverted else 1) * speed_mod
