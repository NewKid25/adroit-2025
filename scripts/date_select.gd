class_name DateSelect extends Node

@onready
var date_labels = $DateLabels
@onready
var character_list = $CharacterList
@onready
var button = $StyledButton

enum MenuStates {
	CHARACTER,
	DATE_NUM,
	PLAY
}

var controller_menu_state:MenuStates = MenuStates.CHARACTER

var is_fading_out:bool = false
var fade_timer:float = 1.0

static var selected_char_index:int = 0
static var selected_date_index:int = 0

var characters : Array[Dictionary] = [
	{
		"date_numbers": [
			{
				"label": "Date 1",
				"conversations": ["res://data/schrodie1.json", "res://data/paulrudd1.json", "res://data/guido1.json"],
				"displayed_names": ["Schrodie", "Paul Rudd", "Guido"],
				"profile_images": [preload("res://assets/art/squareschrodie.png"), preload("res://assets/art/squarepaul.png"), preload("res://assets/art/squareguido.png")]
			},
			{
				"label": "Date 2",
				"conversations": ["res://data/schrodie2.json", "res://data/paulrudd2.json", "res://data/guido2.json"],
				"displayed_names": ["Schrodie", "Paul Rudd", "Guido"],
				"profile_images": [preload("res://assets/art/squareschrodie.png"), preload("res://assets/art/squarepaul.png"), preload("res://assets/art/squareguido.png")]
			}
		]
	},
	{
		"date_numbers": [
			{
				"label": "Date 1",
				"conversations": ["res://data/feldspar1.json", "res://data/cassandrajones1.json", "res://data/professorqubit1.json"],
				"displayed_names": ["Feldspar", "Cassandra", "Prof. Qubit"],
				"profile_images": [preload("res://assets/art/squarefeldspar.png"), preload("res://assets/art/squarecassandra.png"), preload("res://assets/art/squareprofessor.png")]
			},
			# {
			# 	"label": "Date B2",
			# 	"conversations": ["res://data/schrodie2.json", "res://data/paulrudd2.json", "res://data/guido2.json"],
			# 	"displayed_names": ["Schrodie", "Paul Rudd", "Guido"],
			# 	"profile_images": [preload("res://assets/art/squareschrodie.png"), preload("res://assets/art/squarepaul.png"), preload("res://assets/art/squareguido.png")]
			# }
		]
	}
]


func _ready() -> void:
	load_date_labels()
	highlight_character()
	highlight_menu_state()

	for char:CharSelectBundle in character_list.get_children():
		char.area.input_event.connect(
			func(_vp, event, _shape_idx):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
					controller_menu_state = MenuStates.DATE_NUM
					highlight_menu_state()
		)
		char.area.mouse_entered.connect(
			func():
				controller_menu_state = MenuStates.CHARACTER
				highlight_menu_state()
				selected_char_index = char.char_index
				highlight_character()
		)
		
	$WhiteOut.visible = true

	button.mouse_entered.connect(
		func(): 
			controller_menu_state = MenuStates.PLAY
			highlight_menu_state()
	)
	
	button.pressed.connect(func(): is_fading_out = true)


func _process(delta: float):
	$WhiteOut.color.a -= delta
	
	if is_fading_out:
		fade_timer -= delta
		$BlackOut.modulate = Color(1, 1, 1, 1 - fade_timer)
		$BlackOut.visible = true
		if fade_timer <= 0:
			GameManager.characters = [Character.new(), Character.new(), Character.new()]
			for i in range(3):
				GameManager.characters[i].conversation = DataService.get_conversation_from_file(characters[selected_char_index].date_numbers[selected_date_index].conversations[i])
				GameManager.characters[i].displayed_name = characters[selected_char_index].date_numbers[selected_date_index].displayed_names[i]
				GameManager.characters[i].profile_image = characters[selected_char_index].date_numbers[selected_date_index].profile_images[i]
			GameManager.date_idx = selected_date_index + 1

			get_tree().change_scene_to_file("res://scenes/date_screen.tscn")
	else:	
		if Input.is_action_just_pressed("play_card"):
			if controller_menu_state == MenuStates.PLAY:
				is_fading_out = true
			controller_menu_state += 1
			highlight_menu_state()
		if Input.is_action_just_pressed("cancel"):
			if controller_menu_state != MenuStates.CHARACTER:
				controller_menu_state -= 1
				highlight_menu_state()
			else:
				get_tree().change_scene_to_file("res://scenes/title.tscn")
		if Input.is_action_just_pressed("down"):
			if controller_menu_state == MenuStates.DATE_NUM:
				selected_date_index += 1
				highlight_date_label()
			if controller_menu_state == MenuStates.CHARACTER:
				selected_char_index += 1
				highlight_character()
		if Input.is_action_just_pressed("up"):
			if controller_menu_state == MenuStates.DATE_NUM:
				selected_date_index -= 1
				highlight_date_label()
			if controller_menu_state == MenuStates.CHARACTER:
				selected_char_index -= 1
				highlight_character()
	
	# LERPS!!!
	date_labels.position.x = lerp(
		date_labels.position.x,
		192.0 if controller_menu_state >= MenuStates.DATE_NUM else -550.0,
		delta * 10
	)
	date_labels.position.y = lerp(
		date_labels.position.y,
		576.0 - selected_date_index * 140,
		delta * 7.0
	)
	


func highlight_menu_state():
	const TWEEN_DURATION := 0.1

	if controller_menu_state == MenuStates.CHARACTER:
		print("yeah modulatin the date labels out")
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(character_list, "modulate", Color("#ffffff"), TWEEN_DURATION)
		tween.parallel().tween_property(date_labels, "modulate", Color("#adadad"), TWEEN_DURATION)
		tween.parallel().tween_property(button, "modulate", Color("#adadad"), TWEEN_DURATION)
	if controller_menu_state == MenuStates.DATE_NUM:
		print("yeah modulatin the char list out")
		highlight_date_label()
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(character_list, "modulate", Color("#adadad"), TWEEN_DURATION)
		tween.parallel().tween_property(date_labels, "modulate", Color("#ffffff"), TWEEN_DURATION)
		tween.parallel().tween_property(button, "modulate", Color("#adadad"), TWEEN_DURATION)
	if controller_menu_state == MenuStates.PLAY:
		print("yeah modulatin the both")
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(character_list, "modulate", Color("#adadad"), TWEEN_DURATION)
		tween.parallel().tween_property(date_labels, "modulate", Color("#adadad"), TWEEN_DURATION)
		tween.parallel().tween_property(button, "modulate", Color("#ffffff"), TWEEN_DURATION)
		


func highlight_date_label():
	if selected_date_index < 0:
		selected_date_index = 0
	if selected_date_index >= characters[selected_char_index].date_numbers.size():
		selected_date_index = characters[selected_char_index].date_numbers.size() - 1
	const TWEEN_DURATION := 0.1
	for child in date_labels.get_children():
		if child.get_index() == selected_date_index:
			var tween := create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(child, "scale", Vector2.ONE * .9, TWEEN_DURATION)
			tween.parallel().tween_property(child, "modulate", Color("#ffffff"), TWEEN_DURATION)
			tween.parallel().tween_property(child, "position.x", -80, TWEEN_DURATION)
		else:
			var tween := create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(child, "scale", Vector2.ONE * .8, TWEEN_DURATION)
			tween.parallel().tween_property(child, "modulate", Color("#adadad"), TWEEN_DURATION)
			tween.parallel().tween_property(child, "position.x", -90, TWEEN_DURATION)


func highlight_character():
	if selected_char_index < 0:
		selected_char_index = 0
	if selected_char_index >= characters.size():
		selected_char_index = characters.size() - 1
	const TWEEN_DURATION := 0.2
	for child:CharSelectBundle in character_list.get_children():
		if child.char_index == selected_char_index:
			var tween := create_tween()
			tween.tween_property(child, "scale", Vector2.ONE, TWEEN_DURATION)
			tween.parallel().tween_property(child, "modulate", Color("#ffffff"), TWEEN_DURATION)
			tween.parallel().tween_property(child, "position", Vector2(0, (child.char_index - selected_char_index) * 200), TWEEN_DURATION)
			child.z_index = 1
		else:
			var tween := create_tween()
			tween.tween_property(child, "scale", Vector2.ONE * .5, TWEEN_DURATION)
			tween.parallel().tween_property(child, "modulate", Color("#adadad"), TWEEN_DURATION)
			tween.parallel().tween_property(child, "position", Vector2(350 + (abs((child.char_index - selected_char_index)) * 50), (child.char_index - selected_char_index) * 200), TWEEN_DURATION)
			child.z_index = 0
	selected_date_index = 0
	load_date_labels()


func load_date_labels():
	for child in date_labels.get_children():
		child.queue_free()
	var y_pos = 0
	for date in characters[selected_char_index].date_numbers:
		var dlabel : Label = preload("res://scenes/date_select_label.tscn").instantiate()
		dlabel.text = date.label
		dlabel.position.y = y_pos
		dlabel.position.x = -90
		dlabel.scale = Vector2.ONE * .8
		dlabel.modulate = Color("#adadad")
		date_labels.add_child(dlabel)
		y_pos += 160

		dlabel.mouse_entered.connect(
			func():
				selected_date_index = dlabel.get_index()
				print(selected_date_index)
				highlight_date_label()
		)

		dlabel.gui_input.connect(
			func(event):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
					controller_menu_state = MenuStates.PLAY
					highlight_menu_state()
		)


func on_date_label_clicked():
	pass
