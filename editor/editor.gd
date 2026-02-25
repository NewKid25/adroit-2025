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

var all_cards: Array[Card]

func _ready():
	MusicPlayer.stop()
	set_window_scaling_enabled()
	mark_title_all_changes_saved()
	
	make_quit_confirmation_actually_quit()
	
	load_characters()
	select_character(0, 0, SIDE_LEFT)
	all_cards = DataService.get_all_cards()

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

func write_to_file(path, data):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(data + "\n")
	f.close()

func save():
	var path = charactersets[loaded_character_set].dates[loaded_date_idx].get_sided_path(loaded_side)
	var json = serialize_rows_to_json()
	write_to_file(path, json)
	saved = true

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
	if not saved:
		$CannotLoadUnsaved.show()
		return
	loaded_character_set = setid
	loaded_date_idx = dateid
	loaded_side = side
	
	load_rows_from_path(charactersets[setid].dates[dateid].get_sided_path(side))
	select_col(0, 0)

func select_col(rowid, colid):
	selected_row = rowid
	selected_col = colid


func _CharacterList_gui(gui: ELEGui, _delta: float) -> void:
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand()
	
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
	
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand_horiz()
	
	gui.hbox()
	if gui.button("Remove (NO CONFIRM!)", selected_row == 0):
		rows[selected_row].cols.erase(node)
		if rows[selected_row].cols.is_empty():
			rows.remove_at(selected_row)
			select_col(0, 0)
		else:
			select_col(selected_row, max(0, selected_col - 1))
		saved = false
	if gui.button("Duplicate", selected_row == 0):
		rows[selected_row].cols.push_back(node.duplicate(rand_key()))
		select_col(selected_row, len(rows[selected_row].cols) - 1)
		saved = false
	gui.expand_horiz()
	gui.end()
	
	gui.label("Sprite Path")
	if did_change(gui.line(node.sprite), node.sprite):
		saved = false
		node.sprite = changedval
		var path = "res://assets/art/%s" % node.sprite
		if ResourceLoader.exists(path):
			node.spritet = load(path)
		else:
			node.spritet = preload("res://assets/art/EDITOR_unknown_sprite.png")
	
	gui.grid(4)
	gui.expand()
	if selected_row != 0:
		gui.label("")
		gui.expand_horiz()
		gui.label("Flirty")
		gui.expand_horiz()
		gui.label("Funny")
		gui.expand_horiz()
		gui.label("Sentiment")
		gui.expand_horiz()
		
		gui.label("Min")
		node.flirty_min = set_saved(gui.spin(node.flirty_min, 0, 1, 0.1, true, true), node.flirty_min)
		node.funny_min = set_saved(gui.spin(node.funny_min, 0, 1, 0.1, true, true), node.funny_min)
		node.sentiment_min = set_saved(gui.spin(node.sentiment_min, 0, 1, 0.1, true, true), node.sentiment_min)
		
		gui.label("Max")
		node.flirty_max = set_saved(gui.spin(node.flirty_max, 0, 1, 0.1, true, true), node.flirty_max)
		node.funny_max = set_saved(gui.spin(node.funny_max, 0, 1, 0.1, true, true), node.funny_max)
		node.sentiment_max = set_saved(gui.spin(node.sentiment_max, 0, 1, 0.1, true, true), node.sentiment_max)
	gui.end()
	
	gui.end()
	gui.end()
	
	gui.end()

func _NodeView_gui(gui: ELEGui, _delta: float) -> void:
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.vpad(40)
	var add_row_after = -1
	for i in len(rows):
		var row = rows[i]
		var first = i == 0
		
		gui.hbox(40)
		gui.label(i + 1)
		gui.text_centered()
		gui.min_size(60)
		
		for j in range(len(row.cols)):
			var col: DialogNode = row.cols[j]
			gui.vbox()
			gui.hbox()
			if gui.button("Open", selected_row == i and selected_col == j):
				select_col(i, j)
			if not first:
				if did_change(gui.options(col.trigger, Enums.CardPlayOutcome.keys()), col.trigger):
					col.trigger = changedval
					saved = false
				gui.label("(%.1f; %.1f) (%.1f; %.1f) (%.1f; %.1f)" %
					[col.flirty_min, col.flirty_max,
					col.funny_min, col.funny_max,
					col.sentiment_min, col.sentiment_max])
			gui.end()
			
			gui.texturerect_full(preload("res://assets/art/textboxbordered.png"))
			gui.use_as_box()
			gui.wrapped_label(col.text, Color.BLACK)
			gui.fullrect()
			gui.end()
			gui.end()
		
		gui.end()
		
		gui.vpad(15)
		
		gui.hbox()
		gui.hpad(30)
		if gui.button("Add Row Here"):
			add_row_after = i
		gui.end()
		
		gui.vpad(15)
	gui.end()
	gui.end()
	
	if add_row_after != -1:
		var row := DialogRow.new()
		var node := rows[0].cols[0].duplicate(rand_key())
		node.text = "New Row Text"
		row.cols.append(node)
		rows.insert(add_row_after + 1, row)
		select_col(add_row_after + 1, 0)

var dateeditor_needs_save := false
var dateeditor_cooldown := 0.0

## Date Editor Save If Changed
func desic(new, old):
	if new != old:
		dateeditor_needsave()
	return new

func dateeditor_needsave():
	dateeditor_needs_save = true
	dateeditor_cooldown = 1.0

func _DateEditor_gui(gui: ELEGui, _delta: float) -> void:
	var date = charactersets[loaded_character_set].dates[loaded_date_idx]
	
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand()
	
	if gui.button("Move up", loaded_character_set == 0 and loaded_date_idx == 0):
		charactersets[loaded_character_set].dates.erase(date)
		if loaded_date_idx > 0:
			charactersets[loaded_character_set].dates.insert(loaded_date_idx - 1, date)
			loaded_date_idx -= 1
		else:
			loaded_date_idx = len(charactersets[loaded_character_set - 1].dates)
			charactersets[loaded_character_set - 1].dates.insert(len(charactersets[loaded_character_set - 1].dates), date)
			loaded_character_set -= 1
			
			if len(charactersets[loaded_character_set + 1].dates) == 0 and \
					loaded_character_set == len(charactersets) - 2:
				charactersets.pop_back()
		dateeditor_needsave()
	if gui.button("Move down",
			loaded_character_set == len(charactersets) - 1 and
			loaded_date_idx == len(charactersets[loaded_character_set].dates) - 1 and
			loaded_date_idx == 0):
		charactersets[loaded_character_set].dates.erase(date)
		if loaded_date_idx < len(charactersets[loaded_character_set].dates):
			charactersets[loaded_character_set].dates.insert(loaded_date_idx + 1, date)
			loaded_date_idx += 1
		elif loaded_character_set < len(charactersets) - 1:
			charactersets[loaded_character_set + 1].dates.insert(0, date)
			loaded_character_set += 1
			loaded_date_idx = 0
		else:
			var cset = CharacterSet.new()
			cset.dates.append(date)
			loaded_character_set = len(charactersets)
			loaded_date_idx = 0
			charactersets.append(cset)
		dateeditor_needsave()
	if gui.button("Remove (NO CONFIRM! DOESN'T DELETE DIALOG!)", loaded_character_set == 0 and loaded_date_idx == 0):
		charactersets[loaded_character_set].dates.erase(date)
		if len(charactersets[loaded_character_set].dates) == 0:
			charactersets.remove_at(loaded_character_set)
		select_character(0, 0, SIDE_LEFT)
		dateeditor_needsave()
	if gui.button("Duplicate"):
		var newdate = date.duplicate()
		newdate.path_left = "res://data/%s.json" % rand_key()
		newdate.path_middle = "res://data/%s.json" % rand_key()
		newdate.path_right = "res://data/%s.json" % rand_key()
		DirAccess.copy_absolute("res://data/template.json", newdate.path_left)
		DirAccess.copy_absolute("res://data/template.json", newdate.path_middle)
		DirAccess.copy_absolute("res://data/template.json", newdate.path_right)
		charactersets[loaded_character_set].dates.append(newdate)
		select_character(loaded_character_set, len(charactersets[loaded_character_set].dates) - 1, SIDE_LEFT)
		dateeditor_needsave()
	
	gui.label("Label")
	date.label = desic(gui.line(date.label), date.label)
	gui.label("Backgrounds")
	if did_change(gui.line(date.bg_left), date.bg_left):
		date.bg_left = changedval
		if ResourceLoader.exists(date.bg_left):
			date.bgt_left = load(date.bg_left)
		else:
			date.bgt_left = preload("res://assets/art/EDITOR_unknown_background.png")
		dateeditor_needsave()
	if did_change(gui.line(date.bg_middle), date.bg_middle):
		date.bg_middle = changedval
		if ResourceLoader.exists(date.bg_middle):
			date.bgt_middle = load(date.bg_middle)
		else:
			date.bgt_middle = preload("res://assets/art/EDITOR_unknown_background.png")
		dateeditor_needsave()
	if did_change(gui.line(date.bg_right), date.bg_right):
		date.bg_right = changedval
		if ResourceLoader.exists(date.bg_right):
			date.bgt_right = load(date.bg_right)
		else:
			date.bgt_right = preload("res://assets/art/EDITOR_unknown_background.png")
		dateeditor_needsave()
	gui.label("Profiles")
	if did_change(gui.line(date.profile_left), date.profile_left):
		date.profile_left = changedval
		if ResourceLoader.exists(date.profile_left):
			date.profilet_left = load(date.profile_left)
		else:
			date.profilet_left = preload("res://assets/art/EDITOR_unknown_pfp.png")
		dateeditor_needsave()
	if did_change(gui.line(date.profile_middle), date.profile_middle):
		date.profile_middle = changedval
		if ResourceLoader.exists(date.profile_middle):
			date.profilet_middle = load(date.profile_middle)
		else:
			date.profilet_middle = preload("res://assets/art/EDITOR_unknown_pfp.png")
		dateeditor_needsave()
	if did_change(gui.line(date.profile_right), date.profile_right):
		date.profile_right = changedval
		if ResourceLoader.exists(date.profile_right):
			date.profilet_right = load(date.profile_right)
		else:
			date.profilet_right = preload("res://assets/art/EDITOR_unknown_pfp.png")
		dateeditor_needsave()
	gui.label("Names")
	date.name_left = desic(gui.line(date.name_left), date.name_left)
	date.name_middle = desic(gui.line(date.name_middle), date.name_middle)
	date.name_right = desic(gui.line(date.name_right), date.name_right)
	
	gui.end()
	gui.end()

func _Info_gui(gui: ELEGui, _delta: float) -> void:
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand()
	if gui.button("Save", saved):
		save()
	if gui.button("Quit"):
		quit()
	gui.wrapped_label("Open file: %s" % charactersets[loaded_character_set].dates[loaded_date_idx].get_sided_path(loaded_side))
	
	gui.wrapped_label("Selected dialog key \"%s\" is at coordinates (%d; %d)" %
		[rows[selected_row].cols[selected_col].key, selected_row, selected_col])
	
	gui.scroll()
	gui.expand()
	var sortedcards = all_cards.map(get_card_result)
	sortedcards.sort_custom(card_result_sorter)
	sortedcards = sortedcards.map(stringify_card_result)
	gui.label("Card reactions to the selected dialog:\n%s" %
		"\n".join(sortedcards))
	gui.end()
	
	gui.end()
	gui.end()

var mrcache: MoodRange = null

func get_card_result(card: Card):
	if mrcache == null:
		mrcache = MoodRange.new()
		mrcache.mood_lower_bound = Mood.new()
		mrcache.mood_upper_bound = Mood.new()
	
	var cur: DialogNode = rows[selected_row].cols[selected_col]
	mrcache.mood_lower_bound.flirty = cur.flirty_min
	mrcache.mood_lower_bound.funny = cur.funny_min
	mrcache.mood_lower_bound.sentiment = cur.sentiment_min
	mrcache.mood_upper_bound.flirty = cur.flirty_max
	mrcache.mood_upper_bound.funny = cur.funny_max
	mrcache.mood_upper_bound.sentiment = cur.sentiment_max
	return [card, mrcache.compare_mood(card.mood)]

func stringify_card_result(res):
	return "[%s] %s" % [" ".join(res[1].map(func(x): return Enums.CardPlayOutcome.keys()[x].to_pascal_case())), res[0].text]

func card_result_sorter(a, b):
	return a[1][0] < b[1][0]

func did_change(new, old):
	changedval = new
	return new != old

func set_saved(new, old):
	if new != old:
		saved = false
	return new

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if saved:
			get_tree().quit()
		else:
			quit()

func _input(ev: InputEvent) -> void:
	if ev is not InputEventMouseMotion:
		return
	var event: InputEventMouseMotion = ev
	if not event.button_mask & MOUSE_BUTTON_MASK_MIDDLE and \
		not event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		return
	var scroller: ScrollContainer = $HSplitContainer/VSplitContainer/NodeView.get_child(0).get_child(0)
	scroller.scroll_horizontal -= floor(event.relative.x)
	scroller.scroll_vertical -= floor(event.relative.y)

func _process(delta: float) -> void:
	if dateeditor_needs_save:
		dateeditor_cooldown -= delta
		if dateeditor_cooldown <= 0:
			dateeditor_needs_save = false
			
			write_to_file("res://data/characters.json", serialize_characters_to_json())
