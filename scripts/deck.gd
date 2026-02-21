class_name Deck
extends Node

var cards : Array[Card]
const _MAX_CARDS_IN_DECK = 12

# passing nothing to the constructor generates a random Deck
func _init() -> void:
	var all_cards = DataService.get_all_cards()
	for i in range(12):
		cards.append(all_cards.pick_random())
