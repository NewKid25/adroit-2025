class_name UILoveometer
extends ProgressBar

var love := 0.0
var skip_anim_next := true

func update_love(_love:float):
	love=_love

func _process(delta: float) -> void:
	if skip_anim_next:
		value = love * 100
	else:
		value = lerp(value, love * 100, delta * 5)
	
	$Icon.position.x = (value / max_value) * size.x
	$Icon.position.y = size.y / 2.0
	
	skip_anim_next = false
