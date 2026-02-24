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
	var path_left := ""
	var path_middle := ""
	var path_right := ""

class CharacterSet:
	var dates: Array[DateInfo] = []

var saved := false
var dialog_loaded := false
var loaded_character_set := -1
var loaded_date_idx := -1



var rows: Array[DialogRow] = []
var used_key_cache: Array[String] = []

@onready
var dialog_list: ELEDialogList = $VBoxContainer/Split/DialogNodes/ScrollContainer/DialogList

func _ready():
	set_window_scaling_enabled()
	mark_title_unsaved_changes()
	
	make_quit_confirmation_actually_quit()
	
	load_rows()
	update_rows()

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
	used_key_cache.clear()
	
	var json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/schrodie1.json"))["dialogs"]
	
	var node = json.keys()[0]
	
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
	for row in rows:
		print("--- ROW ---")
		for col in row.cols:
			print("- (%s) %s" % [Enums.CardPlayOutcome.keys()[col.trigger], col.text])
	
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
