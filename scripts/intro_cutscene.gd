extends Node

func next_scene():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	MusicPlayer.play()

func _ready() -> void:
	$AudioStreamPlayer.reparent.call_deferred(get_parent())

func _process(_delta):
	UIHelper.debug_fullscreen_toggle_key()
	
	if Input.is_action_just_pressed("play_card") or Input.is_action_just_pressed("cancel"):
		next_scene()
