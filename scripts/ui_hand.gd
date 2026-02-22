class_name UIHand
extends Node2D

const CARD_WIDTH = 225
const CARD_HEIGHT = 315
const CARD_PADDING = 30
const HALF_SCREEN = 1920 / 2.0
const HALF_SCREEN_HEIGHT = 1080 / 2.0
const CARD_FULL_WIDTH = CARD_WIDTH + CARD_PADDING
const CARD_RESOURCE = preload("res://scenes/card.tscn")
const CARD_MODULATE_NORMAL = Color(0.729, 0.729, 0.729)
const CARD_MODULATE_HELD = Color(1.0, 1.0, 1.0)
const CARD_MODULATE_HIDDEN = Color(0.361, 0.361, 0.361, 0.906)

enum UIHandState {
	Playing,
	Hidden,
	CardGoUpToMiddle
}

signal finish_move(card: Card)

var state := UIHandState.Hidden
var selected := 0
var skip_anim_next_frame := true
var card_go_up_timer := 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if cards_in_hand() == 0:
		return
	
	if state == UIHandState.Playing:
		change_selected()
		animate_cards(delta, false, false)
		
		if Input.is_action_just_pressed("play_card"):
			state = UIHandState.CardGoUpToMiddle
			SfxManager.play_sound(preload("res://assets/sfx/card_use.mp3"))
			card_go_up_timer = 0.0
			UIHelper.joy_shake()
	elif state == UIHandState.Hidden:
		animate_cards(delta, true, false)
	elif state == UIHandState.CardGoUpToMiddle:
		animate_cards(delta, true, true)
		animate_middle_card(delta)
		card_go_up_timer += delta
		if card_go_up_timer > 1.5:
			finish_move.emit(get_selected_card())
			selected -= 1
	
	skip_anim_next_frame = false

func change_selected():
	if cards_in_hand() == 0:
		return
	
	var moved := false
	
	if Input.is_action_just_pressed("left"):
		selected -= 1
		UIHelper.joy_shake()
		moved = true
		SfxManager.play_sound(preload("res://assets/sfx/card_left.mp3"))
	if Input.is_action_just_pressed("right"):
		selected += 1
		UIHelper.joy_shake()
		moved = true
		SfxManager.play_sound(preload("res://assets/sfx/card_right.mp3"))
	
	if Input.is_action_just_pressed("far_left"):
		selected = 0
		UIHelper.joy_shake()
		SfxManager.play_sound(preload("res://assets/sfx/card_left.mp3"))
	if Input.is_action_just_pressed("far_right"):
		selected = 999
		UIHelper.joy_shake()
		SfxManager.play_sound(preload("res://assets/sfx/card_right.mp3"))
	
	if selected < 0:
		selected = 0
	elif selected >= cards_in_hand():
		selected = cards_in_hand() - 1
	
	if moved:
		get_selected_card_node().shake()

func animate_cards(delta: float, state_hidden: bool, skip_selected: bool) -> void:
	var skipaware_cards = cards_in_hand()
	if skip_selected:
		skipaware_cards -= 1
	
	var wid = (skipaware_cards * CARD_FULL_WIDTH) - CARD_FULL_WIDTH
	var hwid = wid / 2.0
	var rot_scale = 0.05 if state_hidden else 0.1
	var xmod = 0.5 if state_hidden else 0.95
	
	var rel_selected = (selected - skipaware_cards / 2.0 + 0.5)
	position.x = clerp(
		position.x,
		HALF_SCREEN - (-0.0 if state_hidden else rel_selected * 20.0),
		delta * 5
	)
	
	for i in range(cards_in_hand()):
		var card: Node2D = get_child(i)
		var is_selected = not state_hidden and i == selected
		
		if skip_selected and i == selected:
			continue
		
		var skipaware_idx = i
		if skip_selected and i > selected:
			skipaware_idx -= 1
		
		var relative_idx = (skipaware_idx - skipaware_cards / 2.0 + 0.5)
		var target_rot = relative_idx * rot_scale
		var yfloater = sin((Time.get_ticks_msec() / 1000.0 * 0.8) + skipaware_idx) * 5.0
		var ymod = (relative_idx * relative_idx) * 10
		
		card.position.x = clerp(
			card.position.x,
			(CARD_FULL_WIDTH * skipaware_idx - hwid) * xmod,
			delta * (5.0 if state_hidden else 3.0)
		)
		card.position.y = clerp(
			card.position.y,
			(120.0 + ymod * 0.2) if state_hidden else
				(-50.0 + yfloater * 0.2) if is_selected else
				(30.0 + ymod + yfloater),
			delta * 8
		)
		card.rotation = clerp(
			card.rotation,
			target_rot * (0.1 if is_selected else 1.0),
			delta * 8
		)
		card.modulate = objlerp(
			card.modulate,
			CARD_MODULATE_HIDDEN if state_hidden else
				CARD_MODULATE_HELD if is_selected else
				CARD_MODULATE_NORMAL,
			delta * 10
		)
		card.z_index = 1 if is_selected else 0

func clerp(from, to, x):
	if skip_anim_next_frame:
		return to
	return lerp(from, to, x)

func objlerp(from, to, x):
	if skip_anim_next_frame:
		return to
	return from.lerp(to, x)

func animate_middle_card(delta: float) -> void:
	var card = get_selected_card_node()
	card.global_position = objlerp(
		card.global_position,
		Vector2(HALF_SCREEN, HALF_SCREEN_HEIGHT - CARD_HEIGHT / 2.0),
		delta * 5
	)
	card.rotation = clerp(
		card.rotation,
		0.0,
		delta * 5
	)
	#if card_go_up_timer > 1.8:
	if true:
		card.shake(card_go_up_timer / 1.5)
		UIHelper.joy_shake()
	var s = (card_go_up_timer - 1.3) / 0.2
	s = clamp(s, 0, 1)
	s *= s
	s *= 0.3
	s += 1
	s -= pow(card_go_up_timer, 1.3) * 0.09
	s += max(0, pow(card_go_up_timer - 0.3, 6) * 0.03)
	card.body_scale = s

func get_card_node(idx: int) -> UICard:
	var x: Node = get_child(idx)
	if x == null: return null
	if x is not UICard: return null
	return x

func get_selected_card_node() -> UICard:
	return get_card_node(selected)

func get_selected_card() -> Card:
	return get_selected_card_node().card

func cards_in_hand() -> int:
	return get_child_count()

func get_card_node_by_card(card: Card) -> UICard:
	for child in get_children():
		if "card" in child and child.card == card:
			return child
	return null

func add_card(card: Card) -> void:
	var card_node: UICard = CARD_RESOURCE.instantiate()
	card_node.position.x = (cards_in_hand() * CARD_FULL_WIDTH) / 2.0
	card_node.card = card
	card_node.modulate = Color.TRANSPARENT
	add_child(card_node)

func remove_card(card: Card) -> void:
	get_card_node_by_card(card).queue_free()
