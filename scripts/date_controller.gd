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
var conversation1: Conversation = null
var current_line1: String = ""
var conversation2: Conversation = null
var current_line2: String = ""
var conversation3: Conversation = null
var current_line3: String = ""

func _ready():
	# TODO: hardcoding
	conversation1 = DataService.get_conversation_from_file("res://data/shrodie-temp.json")
	current_line1 = conversation1.dialogs.keys()[0]
	conversation2 = DataService.get_conversation_from_file("res://data/shrodie-temp.json")
	current_line2 = conversation2.dialogs.keys()[0]
	conversation3 = DataService.get_conversation_from_file("res://data/shrodie-temp.json")
	current_line3 = conversation3.dialogs.keys()[0]

## Plays after animation
func begin() -> GameEvent:
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	card_added.emit(new_demo_card())
	return get_current_gameevent()

## Plays when a card is chosen
func play_card(card: Card) -> GameEvent:
	card_removed.emit(card)
	card_added.emit(new_demo_card())
	return get_current_gameevent()

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

func get_current_gameevent() -> GameEvent:
	var ev := GameEvent.new()
	
	ev.chat_event = ChatEvent.new()
	if current_line1:
		ev.chat_event.line1 = conversation1.dialogs[current_line1].text
	else:
		ev.chat_event.line1 = ""
	if current_line2:
		ev.chat_event.line2 = conversation2.dialogs[current_line2].text
	else:
		ev.chat_event.line2 = ""
	if current_line3:
		ev.chat_event.line3 = conversation3.dialogs[current_line3].text
	else:
		ev.chat_event.line3 = ""
	
	current_line1 = get_next_line(conversation1, current_line1)
	current_line2 = get_next_line(conversation2, current_line2)
	current_line3 = get_next_line(conversation3, current_line3)
	
	ev.is_there_more_after_this = current_line1 or current_line2 or current_line3
	return ev

func get_next_line(conversation: Conversation, current_line: String) -> String:
	var dialog := conversation.dialogs[current_line]
	
	if len(dialog.nexts) == 0:
		return ""
	
	var next = null
	if Enums.CardPlayOutcome.ALL_SUCCESS in dialog.nexts:
		next = dialog.nexts[Enums.CardPlayOutcome.ALL_SUCCESS]
	elif Enums.CardPlayOutcome.DEFAULT in dialog.nexts:
		next = dialog.nexts[Enums.CardPlayOutcome.DEFAULT]
	else:
		next = dialog.nexts[dialog.nexts.keys()[0]]
	return next

func new_demo_card() -> Card:
	DEMO_card_index += 1
	return new_card("Demo %d" % DEMO_card_index)
