extends Node2D

var loveometers : Array[UILoveometer] =[null, null, null]
var loveometer_labels : Array[Label] = [null, null, null]
var success_labels :  Array[Label] = [null, null, null]
var fail_labels :  Array[Label] = [null, null, null]

func _ready() -> void:
	loveometers = [$Center/VBox/Grid/Loveometer1,
					$Center/VBox/Grid/Loveometer2,
					$Center/VBox/Grid/Loveometer3]
	loveometer_labels = [$Center/VBox/Grid/LoveText1,
						$Center/VBox/Grid/LoveText4,
						$Center/VBox/Grid/LoveText5]
	success_labels = [$Center/VBox/Grid/Successful1,
						$Center/VBox/Grid/Successful2,
						$Center/VBox/Grid/Successful3]
	fail_labels = [$Center/VBox/Grid/Failed1,
					$Center/VBox/Grid/Failed2,
					$Center/VBox/Grid/Failed3]
	for i in range(3):
		var character = GameManager.characters[i]
		loveometers[i]._on_update_affection(character.affection, character.goal_affection)
		loveometer_labels[i].text = str(int(character.affection/character.goal_affection*100)) +"% Affection!"
		success_labels[i].text = str(character.cards_correct)
		fail_labels[i].text = str(character.cards_incorrect)

func _process(_delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()
