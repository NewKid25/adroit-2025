class_name UICard
extends Node2D

var card: Card

func _ready():
	$Text.text = card.text
