class_name UILoveometer
extends ProgressBar

var love := 0.0
@export
var skip_anim_next := true

func _on_update_affection(affection:float, goal_affection):
	love=affection/goal_affection

func _process(delta: float) -> void:
	if not visible:
		return
	
	if skip_anim_next:
		value = love * 100
	else:
		value = lerp(value, love * 100, delta * 5)
	
	$Icon.position.x = (value / max_value) * size.x
	$Icon.position.y = size.y / 2.0
	
	skip_anim_next = false
