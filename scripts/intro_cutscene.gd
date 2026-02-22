extends Node

func next_scene():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	MusicPlayer.play()

func _process(_delta):
	if Input.is_action_just_pressed("play_card") or Input.is_action_just_pressed("play_card_mouse"):
		next_scene()