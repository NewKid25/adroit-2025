class_name UICard
extends Node2D

var card: Card
var body_scale: float = 1.0

func _ready():
	$Body/Centerer/Text.text = card.text

func shake(scl := 1.0) -> void:
	#$Body.position.x = dir * 15
	$Body.position.x = randf_range(-10 * scl, 10 * scl)
	$Body.position.y = randf_range(-10 * scl, 10 * scl)

func _process(delta: float) -> void:
	$Body.position.x = lerp(
		$Body.position.x,
		0.0,
		delta * 8
	)
	$Body.position.y = lerp(
		$Body.position.y,
		0.0,
		delta * 8
	)
	$Body/Centerer.scale = Vector2(body_scale, body_scale)
