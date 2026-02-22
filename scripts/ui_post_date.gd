extends Node2D

enum UIPD_State {
	FadingIn,
	FadingOut,
	Main
}

var state := UIPD_State.FadingIn
var fade_time := 0.0
var time_between := 0.0
var viscount := 0

var lock_out_time := 3.0

var displayed_names : Array[Label] = [null, null, null]
var profiles : Array[TextureRect] = [null, null, null]
var loveometers : Array[UILoveometer] =[null, null, null]
var loveometer_labels : Array[Label] = [null, null, null]
var success_labels :  Array[Label] = [null, null, null]
var fail_labels :  Array[Label] = [null, null, null]

@onready
var to_show = []

func _ready() -> void:
	displayed_names = [$Center/VBox/Grid/Character1/Sprite,
						$Center/VBox/Grid/Character2/Sprite,
						$Center/VBox/Grid/Character3/Sprite]
	profiles = [$Center/VBox/Grid/Character1/Name,
				$Center/VBox/Grid/Character2/Name,
				$Center/VBox/Grid/Character3/Name]
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
		displayed_names[i].text = character.displayed_name
		profiles[i].texture = character.profile_image
		loveometers[i].love = character.affection / character.goal_affection
		loveometer_labels[i].text = str(int(character.affection/character.goal_affection*100)) +"% Affection!"
		success_labels[i].text = str(character.cards_correct)
		fail_labels[i].text = str(character.cards_incorrect)
	
	$BlackOut.visible = true
	to_show = $Center/VBox/Grid.get_children().slice(5)
	to_show.push_back($StyledButton)
	for it in to_show:
		it.modulate = Color.TRANSPARENT
	
	$StyledButton.pressed.connect(leave_pressed)

const BEGIN_TIME = 0.5
const PADDING_TIME = 0.2
const PADDING_TIME_PADDING = 0.2

func _process(delta: float) -> void:
	UIHelper.debug_fullscreen_toggle_key()

	if state == UIPD_State.FadingIn:
		fade_time += delta
		$BlackOut.modulate.a = 1 - fade_time
		if fade_time >= BEGIN_TIME:
			time_between += delta
			var padding_time = PADDING_TIME
			if viscount % 5 == 0:
				padding_time += PADDING_TIME_PADDING
			if time_between >= padding_time:
				time_between = 0.0
				to_show[viscount].modulate = Color.WHITE
				if (viscount % 5) == 3:
					$Successful.play()
				elif (viscount % 5) == 4:
					$Alt.play()
				elif (viscount % 5) == 2:
					$Alt.play()
				else:
					$Blip.play()
				viscount += 1
				UIHelper.joy_shake()
		if viscount == len(to_show):
			state = UIPD_State.Main
	elif state == UIPD_State.FadingOut:
		fade_time += delta
		if fade_time >= 1.0:
			get_tree().change_scene_to_file("res://scenes/title.tscn")
		$BlackOut.modulate.a = fade_time
	elif state == UIPD_State.Main:
		if lock_out_time > 0:
			lock_out_time -= delta
		elif Input.is_action_just_pressed("play_card"):
			leave_pressed()

func leave_pressed() -> void:
	if state != UIPD_State.Main:
		return
	state = UIPD_State.FadingOut
	fade_time = 0.0
	UIHelper.joy_shake()
	SfxManager.play_sound(preload("res://assets/sfx/default_alt.wav"))
