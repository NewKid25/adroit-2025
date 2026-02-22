extends Node

func next_scene():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	MusicPlayer.play()
	UIHelper.joy_shake()

@onready
var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	music.reparent.call_deferred(get_parent())
	music.finished.connect(music.queue_free)

func _process(_delta):
	UIHelper.debug_fullscreen_toggle_key()
	
	if Input.is_action_just_pressed("play_card") or Input.is_action_just_pressed("cancel"):
		next_scene()
		music.stop()
		music.queue_free()
