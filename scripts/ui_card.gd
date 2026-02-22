class_name UICard
extends Node2D

var card: Card
var body_scale: float = 1.0

func _ready():
	$Body/Centerer/Text.text = card.text
	scale_text_fit_width($Body/Centerer/Text)


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


func scale_text_fit_width(label:Label):	
	var current_font_size:int = label.get_theme_font_size("font_size")

	var total_text_height:float = label.get_theme_font("font").get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_CENTER, label.size.x, current_font_size).y
	if (label.has_theme_font_size_override("font_size")):
		label.remove_theme_font_size_override("font_size")
	label.add_theme_font_size_override("font_size", min(26, floor(current_font_size * (label.size.y / total_text_height))))