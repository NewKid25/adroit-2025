extends Node2D

var fading_out := false
var fade_time := 0.0

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	$WhiteOut.modulate.a -= delta
	
	if fading_out:
		fade_time += delta
		if fade_time >= 1.0:
			get_tree().change_scene_to_file("res://scenes/date_screen.tscn")
		$BlackOut.modulate.a = fade_time
	else:
		if Input.is_action_just_pressed("play_card"):
			fading_out = true
