class_name DataService
extends Node2D

func _ready() -> void:
	# TEST CODE TO WRITE A CONVERSATION TO A FILE
	# var dialog = Dialog.new()
	# dialog.text = "dialog"
	# dialog.nexts[Enums.CardPlayOutcome.ALL_SUCCESS] = "id1"


	# var dialog2 = DialogPrompt.new()
	# dialog2.text = "other dialog"
	# dialog2.nexts[Enums.CardPlayOutcome.ALL_SUCCESS] = "id2"

	# var mood = Mood.new()

	# var moodRange = MoodRange.new()
	# moodRange.mood_lower_bound = mood
	# moodRange.mood_upper_bound = mood
	
	# dialog.mood_expectation = moodRange
	# dialog2.mood_expectation = moodRange
	
	# var convo = Conversation.new()
	# convo.dialogs["id1"]=dialog
	# convo.dialogs["id2"] =dialog2
	
	# #dialogStr = JSON.stringify(dialog)
	# var objStr = ForgeJSONGD.class_to_json(convo)
	# ForgeJSONGD.store_json_file("res://data/test.json", objStr)
	# dialogStr = JSON.stringify(JsonClassConverter.class_to_json(dialog, true))

	#var a_dia = ForgeJSONGD.json_string_to_class(Dialog, dialogStr)
	var a = ForgeJSONGD.json_file_to_class(Conversation, "res://data/test.json")
	#print(a.nexts[Enums.CardPlayOutcome.ALL_SUCCESS])
	var bob = a.dialogs["id2"].mood_expectation
	print(bob)
	# print(dialogStr)
	return
