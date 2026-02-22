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

var date_deck = Deck.new()
var outcomes:Array = []
var loveometers : Array[UILoveometer]


func _ready():
	# TODO: hardcoding
	conversation1 = DataService.get_conversation_from_file("res://data/schrodie1.json")
	current_line1 = conversation1.dialogs.keys()[0]
	conversation2 = DataService.get_conversation_from_file("res://data/paulrudd1.json")
	current_line2 = conversation2.dialogs.keys()[0]
	conversation3 = DataService.get_conversation_from_file("res://data/guido1.json")
	current_line3 = conversation3.dialogs.keys()[0]
	#get loveometers and associate them with characters
	loveometers = [$"../Date1/Loveometer", $"../Date3/Loveometer", $"../Date2/Loveometer"]
	for i in range(3):	
		GameManager.characters[i].affection_update.connect(loveometers[i].update_love)
	return

func get_date_number() -> int:
	return 1

## Plays after animation
func begin() -> GameEvent:
	for i in range(4): card_added.emit(date_deck.cards.pop_front())

	return get_current_gameevent()

## Plays when a card is chosen
func play_card(card: Card) -> GameEvent:
	card_removed.emit(card)
	jump_next(card.mood)
	GameManager.characters[0].affection = .5
	card_added.emit(date_deck.cards.pop_front())
	return get_current_gameevent()

func new_card(text: String, mood: Mood) -> Card:
	var c = Card.new()
	c.text = text
	c.mood = mood
	return c

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
	
	ev.is_there_more_after_this = \
		len(conversation1.dialogs[current_line1].nexts) > 0 or \
		len(conversation2.dialogs[current_line2].nexts) > 0 or \
		len(conversation3.dialogs[current_line3].nexts) > 0
	
	return ev

func get_next_line(conversation: Conversation, current_line: String, mood: Mood) -> String:
	var dialog := conversation.dialogs[current_line]
	
	if len(dialog.nexts) == 0:
		return ""
	
	var next = null
	var outcomes := dialog.mood_expectation.compare_mood(mood)

	for outcome in outcomes:
		if outcome in dialog.nexts:
			next = dialog.nexts[outcome]
			if next:
				break
	
	if next == null and Enums.CardPlayOutcome.DEFAULT in dialog.nexts:
		next = dialog.nexts[Enums.CardPlayOutcome.DEFAULT]
	elif next == null:
		next = dialog.nexts[dialog.nexts.keys()[0]]
	return next

func jump_next(mood: Mood) -> void:
	outcomes.clear()
	outcomes.push_back(conversation1.dialogs[current_line1].mood_expectation.compare_mood(mood))
	current_line1 = get_next_line(conversation1, current_line1, mood)
	outcomes.push_back(conversation1.dialogs[current_line2].mood_expectation.compare_mood(mood))
	current_line2 = get_next_line(conversation2, current_line2, mood)
	outcomes.push_back(conversation1.dialogs[current_line3].mood_expectation.compare_mood(mood))
	current_line3 = get_next_line(conversation3, current_line3, mood)

func new_demo_card() -> Card:
	DEMO_card_index += 1
	return new_card(
		"Demo %d" % DEMO_card_index,
		Mood.new(1, 0, 0)
	)
