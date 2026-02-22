extends Node2D

func _ready() -> void:
	$WhiteOut.visible = true
	
	$StyledButton.pressed.connect(leave)

func leave():
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/default_alt.wav"))
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	$WhiteOut.modulate.a -= delta
	
	if Input.is_action_just_pressed("play_card"):
		leave()
