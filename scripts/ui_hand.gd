class_name UIHand
extends Node2D

const CARD_WIDTH = 225
const CARD_PADDING = 30
const HALF_SCREEN = 1920 / 2.0
const CARD_FULL_WIDTH = CARD_WIDTH + CARD_PADDING
const CARD_RESOURCE = preload("res://scenes/card.tscn")
const CARD_MODULATE_NORMAL = Color(0.729, 0.729, 0.729)
const CARD_MODULATE_HELD = Color(1.0, 1.0, 1.0)
const CARD_MODULATE_HIDDEN = Color(0.359, 0.359, 0.359)

enum UIHandState {
	Playing,
	Hidden,
	CardGoUpToMiddle
}

var state := UIHandState.Hidden
var selected := 0
var skip_anim_next_frame := true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dbg_add_card"):
		var card = Card.new()
		card.text = "Debug text!"
		add_card(card)
	
	if cards_in_hand() == 0:
		return
	
	if state == UIHandState.Playing:
		change_selected()
		animate_cards(delta, false)
		
		if Input.is_action_just_pressed("play_card"):
			get_selected_card_node().queue_free()
			selected -= 1
	elif state == UIHandState.Hidden:
		animate_cards(delta, true)
	elif state == UIHandState.CardGoUpToMiddle:
		pass

func change_selected():
	if Input.is_action_just_pressed("left"):
		selected -= 1
	if Input.is_action_just_pressed("right"):
		selected += 1
	
	if selected < 0:
		selected = 0
	elif selected >= cards_in_hand():
		selected = cards_in_hand() - 1

func animate_cards(delta: float, state_hidden: bool) -> void:
	var wid = (cards_in_hand() * CARD_FULL_WIDTH) - CARD_FULL_WIDTH
	var hwid = wid / 2.0
	var rot_scale = 0.05 if state_hidden else 0.1
	var xmod = 0.35 if state_hidden else 0.95
	
	var rel_selected = (selected - cards_in_hand() / 2.0 + 0.5)
	position.x = lerp(
		position.x,
		HALF_SCREEN - rel_selected * 20.0,
		delta * 3
	)
	
	for i in range(cards_in_hand()):
		var card: Node2D = get_child(i)
		var is_selected = not state_hidden and i == selected
		
		var relative_idx = (i - cards_in_hand() / 2.0 + 0.5)
		var target_rot = relative_idx * rot_scale
		var ymod = (relative_idx * relative_idx) * 10
		
		card.position.x = lerp(
			card.position.x,
			(CARD_FULL_WIDTH * i - hwid) * xmod,
			delta * 5
		)
		card.position.y = lerp(
			card.position.y,
			(80.0 + ymod * 0.2) if state_hidden else -50.0 if is_selected else (30.0 + ymod),
			delta * 8
		)
		card.rotation = lerp(
			card.rotation,
			target_rot * (0.1 if is_selected else 1.0),
			delta * 8
		)
		card.modulate = card.modulate.lerp(
			CARD_MODULATE_HIDDEN if state_hidden else
				CARD_MODULATE_HELD if is_selected else
				CARD_MODULATE_NORMAL,
			delta * 10
		)
		card.z_index = 1 if is_selected else 0

func get_card_node(idx: int) -> UICard:
	var x: Node = get_child(idx)
	if x == null: return null
	if x is not UICard: return null
	return x

func get_selected_card_node() -> UICard:
	return get_card_node(selected)

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
	add_child(card_node)
