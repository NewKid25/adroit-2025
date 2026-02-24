extends Control

class DialogNode:
	var key := ""
	var text := ""
	var sprite := ""
	var flirty_min := 0.0
	var flirty_max := 0.0
	var funny_min := 0.0
	var funny_max := 0.0
	var sentiment_min := 0.0
	var sentiment_max := 0.0
	var trigger := Enums.CardPlayOutcome.ALL_SUCCESS

class DialogRow:
	var cols: Array[DialogNode] = []

class DateInfo:
	var label := ""
	
	var path_left := ""
	var bg_left := ""
	var name_left := ""
	var profile_left := ""
	
	var path_middle := ""
	var bg_middle := ""
	var name_middle := ""
	var profile_middle := ""
	
	var path_right := ""
	var bg_right := ""
	var name_right := ""
	var profile_right := ""
	
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

var saved := true
var dialog_loaded := false
var loaded_character_set := -1
var loaded_date_idx := -1
var loaded_side := -1

var selected_row := -1
var selected_col := -1

const SIDE_LEFT = 0
const SIDE_MIDDLE = 1
const SIDE_RIGHT = 2

var charactersets: Array[CharacterSet] = []
var rows: Array[DialogRow] = []
var used_key_cache: Array[String] = []

@onready
var dialog_list: ELEDialogList = $VBoxContainer/Split/DialogNodes/ScrollContainer/DialogList
@onready
var node_character_sets: ELECharacterSets = $VBoxContainer/Split/VBoxContainer/CharacterSets
@onready
var dialog_inspector: ELEDialogInspector = $VBoxContainer/Split/DialogNodes/DialogInspector

func _ready():
	set_window_scaling_enabled()
	mark_title_unsaved_changes()
	
	make_quit_confirmation_actually_quit()
	
	load_characters()
	update_characters()
	
	select_character(0, 0, SIDE_LEFT)

func _on_popup_menu_index_pressed(index: int) -> void:
	match index:
		0:
			pass
		1:
			quit()
		_:
			print("Unknown idx pressed")


func quit():
	if saved:
		actually_quit()
	else:
		$QuitConfirmation.show()

func make_quit_confirmation_actually_quit():
	$QuitConfirmation.confirmed.connect(actually_quit)

func actually_quit():
	set_window_scaling_disabled()
	mark_title_game()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func set_window_scaling_enabled():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED

func set_window_scaling_disabled():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

func mark_title_all_changes_saved():
	get_window().title = "Entangled Love Editor"

func mark_title_unsaved_changes():
	get_window().title = "Entangled Love Editor | (UNSAVED CHANGES!)"

func mark_title_game():
	get_window().title = ProjectSettings.get_setting("application/config/name")

func load_rows():
	rows.clear()
	
	var json: Dictionary = \
		JSON.parse_string(FileAccess.get_file_as_string(
			charactersets[loaded_character_set].dates[loaded_date_idx].get_sided_path(loaded_side)
		))["dialogs"]
	
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

func update_rows():
	#debug_print_rows()
	
	var drow := dialog_list.get_row(0)
	drow.mark_first_row()
	drow.set_text(0, rows[0].cols[0].text)
	
	for i in range(1, len(rows)):
		drow = dialog_list.add_row()
		drow.mark_row_idx(i)
		
		for j in range(1, len(rows[i].cols)):
			drow.add_column()
		
		for j in range(len(rows[i].cols)):
			drow.set_range(
				j,
				rows[i].cols[j].flirty_min,
				rows[i].cols[j].flirty_max,
				rows[i].cols[j].funny_min,
				rows[i].cols[j].funny_max,
				rows[i].cols[j].sentiment_min,
				rows[i].cols[j].sentiment_max
			)
			drow.set_trigger(j, rows[i].cols[j].trigger)
			drow.set_text(j, rows[i].cols[j].text)

func debug_print_rows():
	for row in rows:
		print("--- ROW ---")
		for col in row.cols:
			print("- (%s) %s" % [Enums.CardPlayOutcome.keys()[col.trigger], col.text])

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
			
			obj.dates.push_back(obj2)
		
		charactersets.push_back(obj)

func update_characters():
	for cset in charactersets:
		var node = node_character_sets.add_set()
		for date in cset.dates:
			var node2 = node.add_date()
			node2.set_bckgs(date.bg_left, date.bg_middle, date.bg_right)
			node2.set_name_data(
				date.label,
				date.name_left, date.path_left,
				date.name_middle, date.path_middle,
				date.name_right, date.path_right
			)
			node2.set_profiles(date.profile_left, date.profile_middle, date.profile_right)

func select_character(setid, dateid, side):
	loaded_character_set = setid
	loaded_date_idx = dateid
	loaded_side = side
	
	load_rows()
	update_rows()
	
	$VBoxContainer/HBoxContainer/LoadedFile.text = "Open File: %s" % charactersets[setid].dates[dateid].get_sided_path(side)
	
	select_col(0, 0)

func select_col(rowid, colid):
	selected_row = rowid
	selected_col = colid
	
	var data = rows[rowid].cols[colid]
	
	dialog_inspector.set_image(data.sprite)
	dialog_inspector.set_text(data.text)
	dialog_inspector.set_moods(data.flirty_min, data.flirty_max, data.funny_min, data.funny_max, data.sentiment_min, data.sentiment_max)
