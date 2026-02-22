class_name UIHelper
extends Node

static func joy_shake(strength := 0.0):
	strength = clamp(strength, 0.0, 1.0)
	Input.start_joy_vibration(0, 0.6 + strength * 0.4, 0.2 + strength * 0.8, 0.1)

static func debug_fullscreen_toggle_key() -> void:
	if Input.is_action_just_pressed("dbg_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
