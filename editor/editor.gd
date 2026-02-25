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
	
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand_horiz()
	
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
	if true:
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
	gui.control()
	gui.min_size(null, 40)
	gui.end()
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
	gui.end()
	gui.end()

func _Info_gui(gui: ELEGui, _delta: float) -> void:
	gui.scroll()
	gui.expand()
	gui.vbox()
	gui.expand()
	if gui.button("Save", saved):
		saved = true
	if gui.button("Quit"):
		quit()
	gui.label("Open file: %s" % charactersets[loaded_character_set].dates[loaded_date_idx].get_sided_path(loaded_side))
	
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
	var scroller: ScrollContainer = $HSplitContainer/VSplitContainer/ColorRect/NodeView.get_child(0).get_child(0)
	scroller.scroll_horizontal -= event.relative.x
	scroller.scroll_vertical -= event.relative.y
