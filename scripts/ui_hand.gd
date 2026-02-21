class_name UIHand
extends Node2D

var selected = 0

const CARD_WIDTH = 150
const CARD_PADDING = 20

const CARD_FULL_WIDTH = CARD_WIDTH + CARD_PADDING

const CARD_RESOURCE = preload("res://scenes/card.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dbg_add_card"):
		var card = Card.new()
		card.text = "Debug text!"
		add_card(card)
	
	if cards_in_hand() == 0:
		return
	
	change_selected()
	animate_cards(delta)
	
	if Input.is_action_just_pressed("play_card"):
		get_selected_card_node().queue_free()
		selected -= 1

func change_selected():
	if Input.is_action_just_pressed("left"):
		selected -= 1
	if Input.is_action_just_pressed("right"):
		selected += 1
	
	if selected < 0:
		selected = 0
	elif selected >= cards_in_hand():
		selected = cards_in_hand() - 1

func animate_cards(delta: float):
	var wid = (cards_in_hand() * CARD_FULL_WIDTH) - CARD_FULL_WIDTH
	var hwid = wid / 2.0
	for i in range(cards_in_hand()):
		var card: Node2D = get_child(i)
		var is_selected = i == selected
		
		var target_rot = (i - cards_in_hand() / 2.0 + 0.5) * 0.15
		
		card.position.x = lerp(
			card.position.x,
			CARD_FULL_WIDTH * i - hwid,
			delta * 5
		)
		card.position.y = lerp(
			card.position.y,
			-50.0 if is_selected else 50.0,
			delta * 8
		)
		card.rotation = lerp(
			card.rotation,
			0.0 if is_selected else target_rot,
			delta * 8
		)
		card.modulate.a = lerp(
			card.modulate.a,
			1.0 if is_selected else 0.8,
			delta * 10
		)
		card.z_index = 1 if is_selected else 0

func get_card_node(idx: int) -> UICard:
	var x = get_child(idx)
	if x == null: return x
	if x is not UICard: return get_child(0)
	return x

func get_selected_card_node() -> UICard:
	return get_card_node(selected)

func cards_in_hand() -> int:
	return get_child_count()

func get_card_node_by_card(card: Card) -> UICard:
	for child in get_children():
		if child.card == card:
			return child
	return null

func add_card(card: Card):
	var card_node: UICard = CARD_RESOURCE.instantiate()
	card_node.position.x = (cards_in_hand() * CARD_FULL_WIDTH) / 2.0
	card_node.card = card
	add_child(card_node)
