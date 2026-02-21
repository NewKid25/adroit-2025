class_name MoodRange
extends Object

var mood_lower_bound : Mood
var mood_upper_bound : Mood


func compare_mood(mood:Mood) -> Array[Enums.CardPlayOutcome]:
	var raw_outcomes : Array[Enums.CardPlayOutcome] = [
		_compare_funny(mood),
		_compare_sentiment(mood),
		_compare_flirty(mood)
	]

	var outcomes : Array[Enums.CardPlayOutcome] = []

	for outcome in raw_outcomes:
		if outcome == Enums.CardPlayOutcome.ALL_SUCCESS:
			continue #skip successes
		else:
			outcomes.append(outcome)

	# If empty we succedded on everything
	if outcomes.is_empty() == true:
		outcomes.append(Enums.CardPlayOutcome.ALL_SUCCESS)
	elif outcomes.size() == 3:
		outcomes.append(Enums.CardPlayOutcome.ALL_FAIL)

	return outcomes


func _compare_funny(mood:Mood):
	if mood.funny < mood_lower_bound.funny:
		return Enums.CardPlayOutcome.UNDER_FUNNY
	elif mood.funny > mood_upper_bound.funny:
		return Enums.CardPlayOutcome.OVER_FUNNY
	else:
		return Enums.CardPlayOutcome.ALL_SUCCESS

func _compare_sentiment(mood:Mood):
	if mood.sentiment < mood_lower_bound.sentiment:
		return Enums.CardPlayOutcome.UNDER_SENTIMENT
	elif mood.sentiment > mood_upper_bound.sentiment:
		return Enums.CardPlayOutcome.OVER_SENTIMENT
	else:
		return Enums.CardPlayOutcome.ALL_SUCCESS

func _compare_flirty(mood:Mood):
	if mood.flirty < mood_lower_bound.flirty:
		return Enums.CardPlayOutcome.UNDER_FLIRTY
	elif mood.flirty > mood_upper_bound.flirty:
		return Enums.CardPlayOutcome.OVER_FLIRTY
	else:
		return Enums.CardPlayOutcome.ALL_SUCCESS
