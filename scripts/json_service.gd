class_name DataService
extends Node2D

func _ready() -> void:
	var dialog = Dialog.new()
	dialog.text = "dialog"
	dialog.nexts[Enums.CardPlayOutcome.ALL_SUCCESS] = "other dialog"
	var dialogStr = JSON.stringify(JSON.from_native(dialog, true))
	#dialogStr = JSON.from_native(dialog, true)
#
	#dialogStr = JSON.stringify(dialog)
	dialogStr = ForgeJSONGD.class_to_json_string(dialog)
	# dialogStr = JSON.stringify(JsonClassConverter.class_to_json(dialog, true))

	var a_dia = ForgeJSONGD.json_string_to_class(Dialog, dialogStr)

	print(dialogStr)
