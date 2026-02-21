class_name DataService
extends Node2D

const CARD_FILE_PATH = "res://data/cards.tsv"

static func get_conversation_from_file(file_path: String):
	var conversation = ForgeJSONGD.json_file_to_class(Conversation, file_path)
	return conversation

static func get_all_cards()-> Array[Card]:
	const CARD_FILE_DELIMITER = "\t"
	var card_data_file_str = load_file_txt(CARD_FILE_PATH)
	card_data_file_str = card_data_file_str.replace('\r', '')
	var card_dicts =_table_str_to_dicts(card_data_file_str, '\t')
	
	var cards : Array[Card] =[]
	for card_dict in card_dicts:
		var card = Card.new()
		card.text = card_dict["Text"]
		card.mood = Mood.new(
			float(card_dict["funny"]),
			float(card_dict["sentiment"]),
			float(card_dict["flirty"])
		)
		cards.append(card)
	return cards

static func load_file_txt(file_path:String)->String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	return content
	
static func _table_str_to_dicts(table_str:String, delimiter:String):
	var lines = table_str.split("\n")
	var col_names = lines[0].split(delimiter)
	lines = lines.slice(1,-1)
	var dicts = []
	for line in lines:
		var fields = line.split(delimiter)
		var dict = {}
		for i in col_names.size():
			dict[col_names[i]] = fields[i]
		dicts.append(dict)
	return dicts


func _ready() -> void:
	var cards = get_all_cards()
	return
