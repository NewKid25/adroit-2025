extends ELEBaseEditor

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

var changedval

func _ready():
	MusicPlayer.stop()
	set_window_scaling_enabled()
	mark_title_all_changes_saved()
	
	make_quit_confirmation_actually_quit()
	
	load_characters()
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
	get_tree().auto_accept_quit = false

func actually_quit():
	set_window_scaling_disabled()
	mark_title_game()
	MusicPlayer.play()
	get_tree().auto_accept_quit = true
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

func select_character(setid, dateid, side):
	loaded_character_set = setid
	loaded_date_idx = dateid
	loaded_side = side
	
	load_rows_from_path(charactersets[setid].dates[dateid].get_sided_path(side))
	select_col(0, 0)

func select_col(rowid, colid):
	selected_row = rowid
	selected_col = colid


func _CharacterList_gui(gui: ELEGui, _delta: float) -> void:
	for i in range(len(charactersets)):
		var cset = charactersets[i]
		gui.label("Character Set %d" % (i + 1))
		for j in range(len(cset.dates)):
			var date: DateInfo = cset.dates[j]
			var issel = i == loaded_character_set and j == loaded_date_idx
			
			gui.hbox()
			gui.grid(3)
			gui.texturerect(date.bgt_left, 64)
			gui.texturerect(date.bgt_middle, 64)
			gui.texturerect(date.bgt_right, 64)
			gui.texturerect(date.profilet_left, 64)
			gui.texturerect(date.profilet_middle, 64)
			gui.texturerect(date.profilet_right, 64)
			gui.end()
			
			gui.scroll()
			gui.expand()
			gui.vbox()
			gui.expand()
			gui.hflow()
			if gui.button("Left", issel and loaded_side == SIDE_LEFT):
				select_character(i, j, SIDE_LEFT)
			if gui.button("Middle", issel and loaded_side == SIDE_MIDDLE):
				select_character(i, j, SIDE_MIDDLE)
			if gui.button("Right", issel and loaded_side == SIDE_RIGHT):
				select_character(i, j, SIDE_RIGHT)
			gui.end()
			gui.wrapped_label(
				'"%s" with "%s" (%s) "%s" (%s) and "%s" (%s)' %
				[date.label,
				date.name_left, date.path_left,
				date.name_middle, date.path_middle,
				date.name_right, date.path_right]
			)
			gui.expand_horiz()
			gui.end()
			gui.end()
			gui.end()

func _DialogInspector_gui(gui: ELEGui, _delta: float) -> void:
	var node: DialogNode = rows[selected_row].cols[selected_col]
	
	gui.hbox()
	gui.expand()
	
	gui.texturerect(node.spritet, null, false)
	gui.expand_vert()
	
	if did_change(gui.textedit(node.text), node.text):
		node.text = changedval
		saved = false
	gui.expand()
	
	gui.vbox()
	
	gui.end()
	
	gui.end()

func _NodeView_gui(gui: ELEGui, _delta: float) -> void:
	pass

func _Info_gui(gui: ELEGui, _delta: float) -> void:
	if gui.button("Save", saved):
		saved = true
	if gui.button("Quit"):
		quit()
	gui.label("Open file: %s" % charactersets[loaded_character_set].dates[loaded_date_idx].get_sided_path(loaded_side))


func did_change(new, old):
	changedval = new
	return new != old

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if saved:
			get_tree().quit()
		else:
			quit()
