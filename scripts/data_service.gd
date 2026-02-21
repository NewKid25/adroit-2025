class_name DataService
extends Node2D

static func get_conversation_from_file(file_path: String):
	var conversation = ForgeJSONGD.json_file_to_class(Conversation, file_path)
	return conversation

func _ready() -> void:
	var moodRange = MoodRange.new()

	# bounds
	var lower = Mood.new()
	lower.funny = 1
	lower.sentiment = 1
	lower.flirty = 1

	var upper = Mood.new()
	upper.funny = 5
	upper.sentiment = 5
	upper.flirty = 5

	moodRange.mood_lower_bound = lower
	moodRange.mood_upper_bound = upper

	# test cases
	var tests = [
		{"name": "below range", "f": 0, "s": 0, "fl": 0},
		{"name": "exact lower", "f": 1, "s": 1, "fl": 1},
		{"name": "middle", "f": 3, "s": 3, "fl": 3},
		{"name": "exact upper", "f": 5, "s": 5, "fl": 5},
		{"name": "above range", "f": 6, "s": 6, "fl": 6},
		{"name": "mixed", "f": 0, "s": 3, "fl": 7}
	]

	for t in tests:
		var m = Mood.new()
		m.funny = t.f
		m.sentiment = t.s
		m.flirty = t.fl

		var result = moodRange.compare_mood(m)
		print(t.name, " -> ", result)
