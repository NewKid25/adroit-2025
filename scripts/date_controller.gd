class_name DateController
extends Node

signal card_added(card: Card)
signal card_removed(card: Card)

# TODO: Add emotions here for multiple sprites?
class ChatEvent:
	var line1: String
	var line2: String
	var line3: String

class GameEvent:
	var chat_event: ChatEvent
	var is_there_more_after_this: bool

var DEMO_card_index = 0

## Plays after animation
func begin() -> GameEvent:
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	return get_demo_gameevent()

## Plays when a card is chosen
func play_card(card: Card) -> GameEvent:
	card_removed.emit(card)
	card_added.emit(new_demo_card())
	return get_demo_gameevent()

func new_card(text: String) -> Card:
	var c = Card.new()
	c.text = text
	return c

func get_demo_gameevent() -> GameEvent:
	var ev := GameEvent.new()
	
	ev.chat_event = ChatEvent.new()
	ev.chat_event.line1 = "Debug Line 1"
	ev.chat_event.line2 = "Debug Line 2"
	ev.chat_event.line3 = "Debug Line 3"
	
	ev.is_there_more_after_this = true
	return ev

func new_demo_card() -> Card:
	DEMO_card_index += 1
	return new_card("Demo %d" % DEMO_card_index)
