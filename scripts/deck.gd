class_name Deck
extends Node

var cards : Array[Card]
const _MAX_CARDS_IN_DECK = 12

# passing nothing to the constructor generates a random Deck
func _init() -> void:
	var all_cards = DataService.get_all_cards()
	var full_deck = []
	for i in range(_MAX_CARDS_IN_DECK):
		if full_deck.is_empty():
			full_deck = all_cards.duplicate()
			full_deck.shuffle()
		cards.append(full_deck.pop_back())
