extends Node2D

var fading_out := false
var fade_time := 0.0

var selected_menu_option := 0

func _ready() -> void:
	$WhiteOut.visible = true
	$BlackOut.visible = true

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	$WhiteOut.modulate.a -= delta
	
	if fading_out:
		fade_time += delta
		if fade_time >= 1.0:
			get_tree().change_scene_to_file("res://scenes/date_screen.tscn")
		$BlackOut.modulate.a = fade_time
	#elif not $AnimationPlayer.is_playing():
	else:
		if Input.is_action_just_pressed("play_card"):
			$AnimationPlayer.seek(1000, true)
			if selected_menu_option == 0:
				fading_out = true
			else:
				get_tree().change_scene_to_file("res://scenes/credits.tscn")
			SfxManager.play_sound(preload("res://assets/sfx/default_reaction.wav"))
		elif Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right"):
			selected_menu_option = 1
			$AnimationPlayer.seek(1000, true)
			$AnimationPlayer.play("select_credits")
			SfxManager.play_sound(preload("res://assets/sfx/card_left.wav"))

		elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left"):
			selected_menu_option = 0
			$AnimationPlayer.seek(1000, true)
			$AnimationPlayer.play("select_play")
			SfxManager.play_sound(preload("res://assets/sfx/card_right.wav"))
