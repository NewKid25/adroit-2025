class_name UIDateScreen
extends Node2D

enum UIDS_State {
	DateIntro,
	Speaking,
	Playing
}

enum UIDS_FocusState {
	None,
	All,
	Left,
	Middle,
	Right
}

var state := UIDS_State.DateIntro
var focus := UIDS_FocusState.None
var skip_anim_next_frame := true

const FOCUSED_MODULATE = Color.WHITE
const UNFOCUSED_MODULATE = Color(0.329, 0.329, 0.329)

func _process(delta: float) -> void:
	do_focusing(delta)
	
	skip_anim_next_frame = false

func do_focusing(delta: float) -> void:
	cmod($Date1, is_left_focused(), delta)
	cmod($Date2, is_middle_focused(), delta)
	cmod($Date3, is_right_focused(), delta)
	cmod($HandBackground, is_hand_focused(), delta)

func cmod(node: CanvasItem, focused: bool, delta: float) -> void:
	var target = FOCUSED_MODULATE if focused else UNFOCUSED_MODULATE
	delta *= 6
	if skip_anim_next_frame:
		delta = 1
	# TODO: This can break if the game runs terrible? Is that wanted?
	node.modulate = node.modulate.lerp(target, delta)

#region State Machine Getter Helpers

func is_left_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Left)

func is_middle_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Middle)

func is_right_focused() -> bool:
	return (focus == UIDS_FocusState.All) or (focus == UIDS_FocusState.Right)

func is_hand_focused() -> bool:
	return (focus == UIDS_FocusState.All)

#endregion
