extends Node2D

@export var intensity:float = 0

const SCALAR:float = 200

func _process(delta:float):
	
	var gravity := position * -1
	gravity += Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))

	position += gravity * delta * SCALAR
	position.x = clamp(position.x, -intensity, intensity)
	position.y = clamp(position.y, -intensity, intensity)

	position.x = clampf(position.x, -intensity, intensity)
	position.y = clampf(position.y, -intensity, intensity)

func reset_shake():
	intensity = 0
	position = Vector2.ZERO
