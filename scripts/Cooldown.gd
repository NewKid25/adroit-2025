# Vaguely adapted from the API of deepnightLibs. thank you dead cells

class_name Cooldown
extends Node

var map = {}
var time := 0.0

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0

func mark(key: String, dur: float) -> void:
	var end = get_time() + dur
	if key in map:
		if map[key] < end:
			map[key] = end
	else:
		map[key] = end

func check(key: String) -> bool:
	return key in map and map[key] > get_time()

func reset(key: String) -> void:
	map.erase(key)
