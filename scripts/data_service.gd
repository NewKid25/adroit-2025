class_name DataService
extends Node2D

static func get_conversation_from_file(file_path: String):
	var conversation = ForgeJSONGD.json_file_to_class(Conversation, file_path)
	return conversation
