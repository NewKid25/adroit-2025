class_name ELEBaseEditor
extends Control

class DialogNode:
	var key := ""
	var text := ""
	var sprite := ""
	var spritet := preload("res://assets/art/paul_rudd.png")
	var flirty_min := 0.0
	var flirty_max := 0.0
	var funny_min := 0.0
	var funny_max := 0.0
	var sentiment_min := 0.0
	var sentiment_max := 0.0
	var trigger := Enums.CardPlayOutcome.ALL_SUCCESS
	
	func duplicate(newkey: String) -> DialogNode:
		var node = DialogNode.new()
		node.key = newkey
		node.text = text
		node.sprite = sprite
		node.spritet = spritet
		node.flirty_min = flirty_min
		node.flirty_max = flirty_max
		node.funny_min = funny_min
		node.funny_max = funny_max
		node.sentiment_min = sentiment_min
		node.sentiment_max = sentiment_max
		node.trigger = trigger
		return node

class DialogRow:
	var cols: Array[DialogNode] = []

class DateInfo:
	var label := ""
	
	var path_left := ""
	var bg_left := ""
	var bgt_left := preload("res://assets/art/datearea.png")
	var name_left := ""
	var profile_left := ""
	var profilet_left := preload("res://assets/art/squareschrodie.png")
	
	var path_middle := ""
	var bg_middle := ""
	var bgt_middle := preload("res://assets/art/datearea.png")
	var name_middle := ""
	var profile_middle := ""
	var profilet_middle := preload("res://assets/art/squareschrodie.png")
	
	var path_right := ""
	var bg_right := ""
	var bgt_right := preload("res://assets/art/datearea.png")
	var name_right := ""
	var profile_right := ""
	var profilet_right := preload("res://assets/art/squareschrodie.png")
	
	func get_sided_path(side):
		match side:
			0:
				return path_left
			1:
				return path_middle
			2:
				return path_right

class CharacterSet:
	var dates: Array[DateInfo] = []

var charactersets: Array[CharacterSet] = []
var rows: Array[DialogRow] = []
var used_key_cache: Array[String] = []

func load_rows_from_path(path: String):
	rows.clear()
	
	var json: Dictionary = \
		JSON.parse_string(FileAccess.get_file_as_string(path))["dialogs"]
	
	var node = json.keys()[0]
	used_key_cache.assign(json.keys())
	
	var row := DialogRow.new()
	var root := DialogNode.new()
	root.key = node
	load_col(root, json[node])
	row.cols.push_back(root)
	rows.push_back(row)
	
	var nexts = json[node]["nexts"]
	var nnexts = null
	
	while len(nexts) > 0:
		row = DialogRow.new()
		for nkey in nexts:
			var nval = nexts[nkey]
			var col = DialogNode.new()
			col.key = nval
			col.trigger = int(nkey)
			load_col(col, json[nval])
			row.cols.push_back(col)
			if nnexts == null:
				nnexts = json[nval]["nexts"]
			else:
				assert(json[nval]["nexts"] == nnexts)
		rows.push_back(row)
		nexts = nnexts
		nnexts = null

## Doesn't load col.key
func load_col(col: DialogNode, data: Dictionary):
	if len(data["mood_expectation"]) > 0:
		col.flirty_min = data["mood_expectation"]["mood_lower_bound"]["flirty"]
		col.flirty_max = data["mood_expectation"]["mood_upper_bound"]["flirty"]
		col.funny_min = data["mood_expectation"]["mood_lower_bound"]["funny"]
		col.funny_max = data["mood_expectation"]["mood_upper_bound"]["funny"]
		col.sentiment_min = data["mood_expectation"]["mood_lower_bound"]["sentiment"]
		col.sentiment_max = data["mood_expectation"]["mood_upper_bound"]["sentiment"]
	col.sprite = data["sprite"]
	col.text = data["text"]
	col.spritet = load("res://assets/art/%s" % col.sprite)


func serialize_rows_to_json() -> String:
	var obj = {}
	
	for i in range(len(rows)):
		var row = rows[i]
		var nexts = {}
		if i < len(rows) - 1:
			for col in rows[i + 1].cols:
				nexts[str(col.trigger)] = col.key
		for col in row.cols:
			obj[col.key] = {
				"mood_expectation": {
					"mood_lower_bound": {
						"flirty": col.flirty_min,
						"funny": col.funny_min,
						"sentiment": col.sentiment_min
					},
					"mood_upper_bound": {
						"flirty": col.flirty_max,
						"funny": col.funny_max,
						"sentiment": col.sentiment_max
					},
				},
				"nexts": nexts,
				"sprite": col.sprite,
				"text": col.text
			}
	
	return JSON.stringify({"dialogs": obj}, "\t", false)

func load_characters():
	var json = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json"))
	for cset in json:
		var obj := CharacterSet.new()
		
		for date in cset["date_numbers"]:
			var obj2 := DateInfo.new()
			obj2.label = date["label"]
			
			obj2.path_left = date["conversations"][0]
			obj2.path_middle = date["conversations"][1]
			obj2.path_right = date["conversations"][2]
			
			obj2.name_left = date["displayed_names"][0]
			obj2.name_middle = date["displayed_names"][1]
			obj2.name_right = date["displayed_names"][2]
			
			obj2.profile_left = date["profile_images"][0]
			obj2.profile_middle = date["profile_images"][1]
			obj2.profile_right = date["profile_images"][2]
			
			obj2.bg_left = date["backgrounds"][0]
			obj2.bg_middle = date["backgrounds"][1]
			obj2.bg_right = date["backgrounds"][2]
			
			obj2.profilet_left = load(obj2.profile_left)
			obj2.profilet_middle = load(obj2.profile_middle)
			obj2.profilet_right = load(obj2.profile_right)
			
			obj2.bgt_left = load(obj2.bg_left)
			obj2.bgt_middle = load(obj2.bg_middle)
			obj2.bgt_right = load(obj2.bg_right)
			
			obj.dates.push_back(obj2)
		
		charactersets.push_back(obj)

func serialize_characters_to_json() -> String:
	var chars = []
	for cset in charactersets:
		var csetj = []
		for date in cset.dates:
			csetj.append({
				"label": date.label,
				"conversations": [date.path_left, date.path_middle, date.path_right],
				"displayed_names": [date.name_left, date.name_middle, date.name_right],
				"profile_images": [date.profile_left, date.profile_middle, date.profile_right],
				"backgrounds": [date.bg_left, date.bg_middle, date.bg_right]
			})
		chars.append({
			"date_numbers": csetj
		})
	return JSON.stringify(chars, "\t", false, false)

func debug_print_rows():
	for row in rows:
		print("--- ROW ---")
		for col in row.cols:
			print("- (%s) %s" % [Enums.CardPlayOutcome.keys()[col.trigger], col.text])

var characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

func generate_word(chars, length):
	var word := ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word

func rand_key() -> String:
	var w = generate_word(characters, 8)
	while w in used_key_cache:
		w = generate_word(characters, 8)
	return w
