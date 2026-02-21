extends Node2D

func _process(_delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	if Input.is_action_just_pressed("play_card"):
		get_tree().change_scene_to_file("res://scenes/date_screen.tscn")
