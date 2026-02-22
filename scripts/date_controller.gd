class_name DateController
extends Node

signal card_added(card: Card)
signal card_removed(card: Card)

# TODO: Add emotions here for multiple sprites?
class ChatEvent:
	var lines :Array[String] = ["", "", ""]
	var sprite_paths :Array[String] = ["", "", ""]

class GameEvent:
	var chat_event: ChatEvent
	var is_there_more_after_this: bool

var DEMO_card_index = 0
# var conversations : Array[Conversation] = [null, null, null]
var current_lines : Array[String] = ["", "", ""]

var date_deck := Deck.new()
var outcomes:Array = []
var loveometers : Array[UILoveometer]


func _ready():
	#get loveometers and associate them with characters
	loveometers = [$"../Date1/Loveometer", $"../Date2/Loveometer", $"../Date3/Loveometer"]
	GameManager.characters = [Character.new(), Character.new(), Character.new()]

	# If/when character select is implemented:
	# Remove these 3 lines and have char select scene handle
	# set these in the GameManager. (Keep the current_lines call though)
	GameManager.characters[0].conversation = DataService.get_conversation_from_file("res://data/schrodie1.json")
	GameManager.characters[1].conversation = DataService.get_conversation_from_file("res://data/paulrudd1.json")
	GameManager.characters[2].conversation = DataService.get_conversation_from_file("res://data/guido1.json")
	
	for i in range(3): current_lines[i] = GameManager.characters[i].conversation.dialogs.keys()[0]

func get_date_number() -> int:
	return 1

## Plays after animation
func begin() -> GameEvent:
	for i in range(4): card_added.emit(date_deck.cards.pop_front())

	return get_current_gameevent()

## Plays when a card is chosen
func play_card(card: Card) -> GameEvent:
	card_removed.emit(card)
	process_play(card.mood)
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
	for i in range(3):
		if current_lines[i]:
			ev.chat_event.lines[i] = GameManager.characters[i].conversation.dialogs[current_lines[i]].text
			ev.chat_event.sprite_paths[i] = GameManager.characters[i].conversation.dialogs[current_lines[i]].sprite
		else:
			ev.chat_event.line[i] = ""
	
	ev.is_there_more_after_this = false
	for i in range(3):
		if len(GameManager.characters[i].conversation.dialogs[current_lines[i]].nexts) > 0:
			ev.is_there_more_after_this = true
	
	return ev

func get_next_line(conversation: Conversation, current_line: String, mood: Mood) -> String:
	var dialog := conversation.dialogs[current_line]
	
	if len(dialog.nexts) == 0:
		return ""
	
	var next = null
	var _outcomes := dialog.mood_expectation.compare_mood(mood)

	for outcome in _outcomes:
		if outcome in dialog.nexts:
			next = dialog.nexts[outcome]
			if next:
				break
	
	if next == null and Enums.CardPlayOutcome.DEFAULT in dialog.nexts:
		next = dialog.nexts[Enums.CardPlayOutcome.DEFAULT]
	elif next == null:
		next = dialog.nexts[dialog.nexts.keys()[0]]
	return next

func process_play(mood: Mood) -> void:
	outcomes.clear()
	for i in range(3):
		var mood_range :MoodRange = GameManager.characters[i].conversation.dialogs[current_lines[i]].mood_expectation
		var play_outcomes = mood_range.compare_mood(mood)
		if Enums.CardPlayOutcome.ALL_SUCCESS in play_outcomes:
			var score = mood_range.score_mood(mood)
			GameManager.characters[i].affection += score
			GameManager.characters[i].cards_correct += 1
		else:
			GameManager.characters[i].cards_incorrect += 1

		outcomes.push_back(play_outcomes)
		current_lines[i] = get_next_line(GameManager.characters[i].conversation, current_lines[i], mood)
	

func new_demo_card() -> Card:
	DEMO_card_index += 1
	return new_card(
		"Demo %d" % DEMO_card_index,
		Mood.new(1, 0, 0)
	)
