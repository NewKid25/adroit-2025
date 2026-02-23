class_name UIDateScreen
extends Node2D

const FOCUSED_MODULATE = Color.WHITE
const UNFOCUSED_MODULATE = Color(0.329, 0.329, 0.329)

enum UIDS_State {
	DateIntro,
	AnimatingIn,
	AnimatingOut,
	SpeakingLeft,
	SpeakingMiddle,
	SpeakingRight,
	Playing,
	WowText
}

enum UIDS_FocusState {
	None,
	All,
	Left,
	Middle,
	Right
}

var state := UIStateMachine.new()
var focus := UIDS_FocusState.None
var skip_anim_next_frame := true
var game_event: DateController.GameEvent
var stashed_cards: Array[Card] = []

@onready
var controller: DateController = $DateController
@onready
var hand: UIHand = $Hand
@onready
var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	controller.card_added.connect(on_card_added)
	controller.card_removed.connect(on_card_removed)
	hand.finish_move.connect(on_finish_move)
	
	$Overlays.visible = true
	$Overlays/BlackScreen.visible = true
	# TODO: Glow?
	#$GlowShader.visible = true
	
	state.add_state_reflect(UIDS_State.DateIntro, self, "date_intro")
	state.add_state_reflect(UIDS_State.AnimatingIn, self, "animating_in")
	state.add_state_reflect(UIDS_State.AnimatingOut, self, "animating_out")
	state.add_state_reflect(UIDS_State.SpeakingLeft, self, "speaking_left")
	state.add_state_reflect(UIDS_State.SpeakingMiddle, self, "speaking_middle")
	state.add_state_reflect(UIDS_State.SpeakingRight, self, "speaking_right")
	state.add_state_reflect(UIDS_State.Playing, self, "playing")
	state.add_state_reflect(UIDS_State.WowText, self, "wow_text")
	
	state.set_state_to(UIDS_State.DateIntro)

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	state.call_process(delta)

	do_focusing(delta)
	
	skip_anim_next_frame = false

#region State Machine Getter Helpers

func is_left_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Left)

func is_middle_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Middle)

func is_right_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Right)

func is_hand_focused() -> bool:
	return (focus == UIDS_FocusState.All)

#endregion

#region UI Helpers

@onready
var loveometers: Array[UILoveometer] = [
	$Date1/Loveometer,
	$Date2/Loveometer,
	$Date3/Loveometer
]

func update_loveometers_idx(idx: int) -> void:
	loveometers[idx].love = GameManager.characters[idx].affection / GameManager.characters[idx].goal_affection

func update_loveometers() -> void:
	update_loveometers_idx(0)
	update_loveometers_idx(1)
	update_loveometers_idx(2)

func set_names() -> void:
	$Date1/DateName.text = GameManager.characters[0].displayed_name
	$Date2/DateName.text = GameManager.characters[1].displayed_name
	$Date3/DateName.text = GameManager.characters[2].displayed_name

func do_focusing(delta: float) -> void:
	animate_focus($Date1, is_left_focused(), delta)
	animate_focus($Date2, is_middle_focused(), delta)
	animate_focus($Date3, is_right_focused(), delta)
	animate_focus($HandBackground, is_hand_focused(), delta)

func animate_focus(node: CanvasItem, focused: bool, delta: float) -> void:
	var target = FOCUSED_MODULATE if focused else UNFOCUSED_MODULATE
	delta *= 6
	if skip_anim_next_frame:
		delta = 1
	# TODO: This can break if the game runs terrible? Is that wanted?
	node.modulate = node.modulate.lerp(target, delta)

func scale_text_fit_width(label:Label, text:String="", default_font_size:int=33):	
	var font_size:int = default_font_size + 1
	if text.is_empty():
		text = label.text
	
	var total_text_height:float = 1000
	while (total_text_height > 160.0):
		font_size -= 1
		total_text_height = label.get_theme_font("font").get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, label.size.x, font_size).y
	
	if (label.has_theme_font_size_override("font_size")):
		label.remove_theme_font_size_override("font_size")
	label.add_theme_font_size_override("font_size", font_size)

func set_left_sprite():
	if not game_event.chat_event.sprite_paths[0].is_empty():
		$Date1/Sprite.texture = load("res://assets/art/" + game_event.chat_event.sprite_paths[0])

func set_middle_sprite():
	if not game_event.chat_event.sprite_paths[1].is_empty():
		$Date2/Sprite.texture = load("res://assets/art/" + game_event.chat_event.sprite_paths[1])

func set_right_sprite():
	if not game_event.chat_event.sprite_paths[2].is_empty():
		$Date3/Sprite.texture = load("res://assets/art/" + game_event.chat_event.sprite_paths[2])

func add_stashed_cards() -> void:
	for card in stashed_cards:
		hand.add_card(card)
	stashed_cards.clear()

#endregion

#region Signal Handlers

func on_card_added(card: Card) -> void:
	stashed_cards.push_back(card)

func on_card_removed(card: Card) -> void:
	hand.remove_card(card)

func on_finish_move(card: Card) -> void:
	game_event = controller.play_card(card)
	$FX/CardExplode.emitting = true
	state.set_state_to(UIDS_State.WowText)


#endregion

#region State Date Intro

func enter_state_date_intro():
	game_event = controller.begin()
	hand.skip_anim_next_frame = true
	update_loveometers()
	set_left_sprite()
	set_middle_sprite()
	set_right_sprite()
	set_names()
	add_stashed_cards()
	state.set_state_to(UIDS_State.AnimatingIn)

func exit_state_date_intro():
	pass

func process_state_date_intro(_delta: float):
	pass

#endregion

#region State Animating In

func enter_state_animating_in():
	focus = UIDS_FocusState.None
	hand.state = UIHand.UIHandState.Hidden
	$Overlays/StartText.text = "Dates %d" % controller.get_date_number()
	animator.play("start")

func exit_state_animating_in():
	pass

func process_state_animating_in(_delta: float):
	if not $AnimationPlayer.is_playing():
		state.set_state_to(UIDS_State.SpeakingLeft)

#endregion

#region State Animating Out

func enter_state_animating_out():
	focus = UIDS_FocusState.All
	hand.state = UIHand.UIHandState.Hidden
	animator.play("end")

func exit_state_animating_out():
	pass

func process_state_animating_out(_delta: float):
	if not $AnimationPlayer.is_playing():
		get_tree().change_scene_to_file("res://scenes/post_date.tscn")

#endregion

#region State Speaking General Variables

var speaking_timer := 0.0

#endregion

#region State Speaking Left

func enter_state_speaking_left():
	focus = UIDS_FocusState.Left
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/default_reaction.wav"))
	scale_text_fit_width($Date1/DateText, game_event.chat_event.lines[0])
	set_left_sprite()

func exit_state_speaking_left():
	pass

func process_state_speaking_left(delta: float):
	speaking_timer += delta * 80
	$Date1/DateText.text = game_event.chat_event.lines[0]
	$Date1/DateText.visible_characters = floor(speaking_timer)
	if speaking_timer > len(game_event.chat_event.lines[0]) + 50:
		state.set_state_to(UIDS_State.SpeakingMiddle)

#endregion

#region State Speaking Middle

func enter_state_speaking_middle():
	focus = UIDS_FocusState.Middle
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/default_reaction.wav"))
	scale_text_fit_width($Date2/DateText, game_event.chat_event.lines[1])
	set_middle_sprite()

func exit_state_speaking_middle():
	pass

func process_state_speaking_middle(delta: float):
	speaking_timer += delta * 80
	$Date2/DateText.text = game_event.chat_event.lines[1]
	$Date2/DateText.visible_characters = floor(speaking_timer)
	if speaking_timer > len(game_event.chat_event.lines[1]) + 50:
		state.set_state_to(UIDS_State.SpeakingRight)

#endregion

#region State Speaking Right

func enter_state_speaking_right():
	focus = UIDS_FocusState.Right
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/default_reaction.wav"))
	scale_text_fit_width($Date3/DateText, game_event.chat_event.lines[2])
	set_right_sprite()

func exit_state_speaking_right():
	pass

func process_state_speaking_right(delta: float):
	speaking_timer += delta * 80
	$Date3/DateText.text = game_event.chat_event.lines[2]
	$Date3/DateText.visible_characters = floor(speaking_timer)
	if speaking_timer > len(game_event.chat_event.lines[2]) + 50:
		if game_event.is_there_more_after_this:
			state.set_state_to(UIDS_State.Playing)
		else:
			state.set_state_to(UIDS_State.AnimatingOut)

#endregion

#region State Playing

func enter_state_playing():
	focus = UIDS_FocusState.All
	hand.state = UIHand.UIHandState.Playing
	add_stashed_cards()
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/card_shuffle.wav"))

func exit_state_playing():
	pass

func process_state_playing(_delta: float):
	pass

#endregion

#region State Wow Text

const outcome_to_wow_text_scene:Dictionary[Enums.CardPlayOutcome, PackedScene] = {
	Enums.CardPlayOutcome.ALL_SUCCESS: preload("res://scenes/wowtexts/wow_text_success.tscn"),
	Enums.CardPlayOutcome.OVER_FLIRTY: preload("res://scenes/wowtexts/wow_text_over_flirty.tscn"),
	Enums.CardPlayOutcome.OVER_FUNNY: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.OVER_SENTIMENT: preload("res://scenes/wowtexts/wow_text_over_sentimental.tscn"),
	Enums.CardPlayOutcome.UNDER_FLIRTY: preload("res://scenes/wowtexts/wow_text_under_funny.tscn"),
	Enums.CardPlayOutcome.UNDER_FUNNY: preload("res://scenes/wowtexts/wow_text_under_funny.tscn"),
	Enums.CardPlayOutcome.UNDER_SENTIMENT: preload("res://scenes/wowtexts/wow_text_under_sentimental.tscn"),
}

var wow_text_timer := 0.0
var wow_texts_character_index := 0
var wow_texts_outcome_index := 0

func enter_state_wow_text():
	hand.state = UIHand.UIHandState.Hidden

	wow_texts_character_index = 0
	wow_texts_outcome_index = -1

func exit_state_wow_text():
	pass

func process_state_wow_text(delta: float):
	wow_text_timer -= delta
	if wow_text_timer < 0:
		wow_texts_outcome_index += 1
		if wow_texts_outcome_index == controller.outcomes[wow_texts_character_index].size():
			wow_texts_character_index += 1
			wow_texts_outcome_index = 0
			if wow_texts_character_index == 3:
				state.set_state_to(UIDS_State.SpeakingLeft)
				return
		var outcome = controller.outcomes[wow_texts_character_index][wow_texts_outcome_index]
		print(Enums.CardPlayOutcome.keys()[outcome])
		update_loveometers_idx(wow_texts_character_index)
		if outcome in outcome_to_wow_text_scene.keys():
			spawn_wow(outcome_to_wow_text_scene[outcome])

func spawn_wow(wow):
	var w = wow.instantiate()
	prints("Immediately after instantiate:", w.global_position)
	$WowTexts.add_child(w)
	prints("After childing", w.global_position)

	match wow_texts_character_index:
		0:
			focus = UIDS_FocusState.Left
		1:
			focus = UIDS_FocusState.Middle

			w.position.x += get_viewport().content_scale_size.x / 3
		2:
			focus = UIDS_FocusState.Right
			w.position.x += get_viewport().content_scale_size.x / 3 * 2

	prints("After offsetting:", w.global_position)


	w.position.y += 100

	UIHelper.joy_shake()
	wow_text_timer = 0.9

#endregion
