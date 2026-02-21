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

const outcome_to_wow_text_scene:Dictionary[Enums.CardPlayOutcome, PackedScene] = {
	Enums.CardPlayOutcome.ALL_SUCCESS: preload("res://scenes/wowtexts/wow_text_success.tscn"),
	Enums.CardPlayOutcome.OVER_FLIRTY: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.OVER_FUNNY: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.OVER_SENTIMENT: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.UNDER_FLIRTY: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.UNDER_FUNNY: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
	Enums.CardPlayOutcome.UNDER_SENTIMENT: preload("res://scenes/wowtexts/wow_text_over_funny.tscn"),
}

signal wow_text_complete

var state := UIDS_State.DateIntro
var focus := UIDS_FocusState.None
var skip_anim_next_frame := true
var game_event: DateController.GameEvent
var speaking_timer := 0.0
var wow_text_timer := 0.0
var stashed_cards: Array[Card] = []
var wow_texts_character_index := 0
var wow_texts_outcome_index := 0

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
	
	_process(1.0/60.0)

func on_card_added(card: Card) -> void:
	stashed_cards.push_back(card)

func add_stashed_cards() -> void:
	for card in stashed_cards:
		hand.add_card(card)
	stashed_cards.clear()

func on_card_removed(card: Card) -> void:
	hand.remove_card(card)

func on_finish_move(card: Card) -> void:
	game_event = controller.play_card(card)
	set_state_wow_text()

func set_state_left():
	state = UIDS_State.SpeakingLeft
	focus = UIDS_FocusState.Left
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()

func set_state_middle():
	state = UIDS_State.SpeakingMiddle
	focus = UIDS_FocusState.Middle
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()

func set_state_right():
	state = UIDS_State.SpeakingRight
	focus = UIDS_FocusState.Right
	speaking_timer = 0.0
	hand.state = UIHand.UIHandState.Hidden
	UIHelper.joy_shake()

func set_state_playing():
	state = UIDS_State.Playing
	focus = UIDS_FocusState.All
	hand.state = UIHand.UIHandState.Playing
	add_stashed_cards()
	UIHelper.joy_shake()

func set_state_animating_in():
	state = UIDS_State.AnimatingIn
	focus = UIDS_FocusState.None
	hand.state = UIHand.UIHandState.Hidden
	$Overlays/StartText.text = "Dates %d" % controller.get_date_number()
	animator.play("start")

func set_state_animating_out():
	state = UIDS_State.AnimatingOut
	focus = UIDS_FocusState.All
	hand.state = UIHand.UIHandState.Hidden
	animator.play("end")

func set_state_wow_text():
	state = UIDS_State.WowText
	hand.state = UIHand.UIHandState.Hidden

	wow_texts_character_index = 0
	wow_texts_outcome_index = -1


func spawn_wow(wow):
	var w = wow.instantiate()
	match wow_texts_character_index:
		0:
			focus = UIDS_FocusState.Left
		1:
			focus = UIDS_FocusState.Middle
			w.position.x += get_window().size.x / 2
		2:
			focus = UIDS_FocusState.Right
			w.position.x += get_window().size.x

	w.position.y += 100

	UIHelper.joy_shake()
	wow_text_timer = 0.9
	$WowTexts.add_child(w)

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
	
	if state == UIDS_State.DateIntro:
		game_event = controller.begin()
		hand.skip_anim_next_frame = true
		add_stashed_cards()
		set_state_animating_in()
	elif state == UIDS_State.AnimatingIn:
		if not $AnimationPlayer.is_playing():
			set_state_left()
	elif state == UIDS_State.AnimatingOut:
		if not $AnimationPlayer.is_playing():
			get_tree().quit()
	elif state == UIDS_State.SpeakingLeft:
		speaking_timer += delta * 80
		$Date1/DateText.text = game_event.chat_event.line1.substr(0, floor(speaking_timer))
		if speaking_timer > len(game_event.chat_event.line1) + 50:
			set_state_middle()
	elif state == UIDS_State.SpeakingMiddle:
		speaking_timer += delta * 80
		$Date2/DateText.text = game_event.chat_event.line2.substr(0, floor(speaking_timer))
		if speaking_timer > len(game_event.chat_event.line2) + 50:
			set_state_right()
	elif state == UIDS_State.SpeakingRight:
		speaking_timer += delta * 80
		$Date3/DateText.text = game_event.chat_event.line3.substr(0, floor(speaking_timer))
		if speaking_timer > len(game_event.chat_event.line3) + 50:
			if game_event.is_there_more_after_this:
				set_state_playing()
			else:
				set_state_animating_out()
	elif state == UIDS_State.Playing:
		pass
	elif state == UIDS_State.WowText:
		wow_text_timer -= delta
		if wow_text_timer < 0:
			wow_texts_outcome_index += 1
			if wow_texts_outcome_index == controller.outcomes[wow_texts_character_index].size():
				wow_texts_character_index += 1
				wow_texts_outcome_index = 0
				if wow_texts_character_index == 3:
					set_state_left()
			if not state == UIDS_State.SpeakingLeft:
				spawn_wow(outcome_to_wow_text_scene[controller.outcomes[wow_texts_character_index][wow_texts_outcome_index]])

	
	do_focusing(delta)
	
	skip_anim_next_frame = false

func do_focusing(delta: float) -> void:
	cmod($Date1, is_left_focused(), delta)
	cmod($Date2, is_middle_focused(), delta)
	cmod($Date3, is_right_focused(), delta)
	cmod($HandBackground, is_hand_focused(), delta)

func cmod(node: CanvasItem, focused: bool, delta: float) -> void:
	var target = FOCUSED_MODULATE if focused else UNFOCUSED_MODULATE
	delta *= 6
	if skip_anim_next_frame:
		delta = 1
	# TODO: This can break if the game runs terrible? Is that wanted?
	node.modulate = node.modulate.lerp(target, delta)

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
