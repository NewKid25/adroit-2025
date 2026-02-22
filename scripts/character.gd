class_name Character
extends Node

var affection : float:
	get:
		return affection
	set(value):
		affection=value
		affection_update.emit(affection)

signal affection_update(affection: float)
