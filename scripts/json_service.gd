class_name DataService
extends Node2D

func _ready() -> void:
	var dialog = Dialog.new()
	dialog.text = "dialog"
	dialog.nexts[Enums.CardPlayOutcome.ALL_SUCCESS] = "other dialog"
	
	#dialogStr = JSON.stringify(dialog)
	# var dialogStr = ForgeJSONGD.class_to_json(dialog)
	# ForgeJSONGD.store_json_file("res://data/test.json", dialogStr)
	# dialogStr = JSON.stringify(JsonClassConverter.class_to_json(dialog, true))

	#var a_dia = ForgeJSONGD.json_string_to_class(Dialog, dialogStr)
	var a_dia = ForgeJSONGD.json_file_to_class(Dialog, "res://data/test.json")
	print(a_dia.nexts[Enums.CardPlayOutcome.ALL_SUCCESS])
	
	# print(dialogStr)
	return
