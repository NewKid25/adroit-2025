class_name Character
extends Node

var affection : float: 
	get:
		return affection
	set(value):
		affection=value
		affection_update.emit(affection, goal_affection)

var goal_affection :float =10

signal affection_update(affection: float, goal_affection: float)
