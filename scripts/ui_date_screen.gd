class_name UIDateScreen
extends Node2D

const FOCUSED_MODULATE = Color.WHITE
const UNFOCUSED_MODULATE = Color(0.329, 0.329, 0.329)

enum UIDS_State {
	DateIntro,
	Animating,
	SpeakingLeft,
	SpeakingMiddle,
	SpeakingRight,
	Playing
}

enum UIDS_FocusState {
	None,
	All,
	Left,
	Middle,
	Right
}

var state := UIDS_State.DateIntro
var focus := UIDS_FocusState.None
var skip_anim_next_frame := true
var game_event: DateController.GameEvent
var speaking_timer := 0.0
var stashed_cards: Array[Card] = []

@onready
var controller: DateController = $DateController
@onready
var hand: UIHand = $Hand

func _ready() -> void:
	controller.card_added.connect(on_card_added)
	controller.card_removed.connect(on_card_removed)
	hand.finish_move.connect(on_finish_move)

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
	set_state_left()

func set_state_left():
	state = UIDS_State.SpeakingLeft
	focus = UIDS_FocusState.Left
	speaking_timer = 1.0
	hand.state = UIHand.UIHandState.Hidden

func set_state_middle():
	state = UIDS_State.SpeakingMiddle
	focus = UIDS_FocusState.Middle
	speaking_timer = 1.0
	hand.state = UIHand.UIHandState.Hidden

func set_state_right():
	state = UIDS_State.SpeakingRight
	focus = UIDS_FocusState.Right
	speaking_timer = 1.0
	hand.state = UIHand.UIHandState.Hidden

func set_state_playing():
	state = UIDS_State.Playing
	focus = UIDS_FocusState.All
	hand.state = UIHand.UIHandState.Playing
	add_stashed_cards()

func _process(delta: float) -> void:
	debug_fullscreen_toggle_key()
	
	if state == UIDS_State.DateIntro:
		game_event = controller.begin()
		hand.skip_anim_next_frame = true
		add_stashed_cards()
		state = UIDS_State.Animating
	elif state == UIDS_State.Animating:
		set_state_left()
	elif state == UIDS_State.SpeakingLeft:
		$Date1/DateText.text = game_event.chat_event.line1
		speaking_timer -= delta
		if speaking_timer < 0:
			set_state_middle()
	elif state == UIDS_State.SpeakingMiddle:
		$Date2/DateText.text = game_event.chat_event.line2
		speaking_timer -= delta
		if speaking_timer < 0:
			set_state_right()
	elif state == UIDS_State.SpeakingRight:
		$Date3/DateText.text = game_event.chat_event.line3
		speaking_timer -= delta
		if speaking_timer < 0:
			set_state_playing()
	elif state == UIDS_State.Playing:
		pass
	
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

func debug_fullscreen_toggle_key() -> void:
	if Input.is_action_just_pressed("dbg_fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN

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
