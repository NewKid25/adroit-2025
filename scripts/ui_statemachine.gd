class_name UIStateMachine
extends Node

var last_state := -1
var state := -1

class UIStateInstance:
	var enter: Callable
	var exit: Callable
	var process: Callable

var states: Array[UIStateInstance] = []

func set_state_to(new_state: int) -> void:
	last_state = state
	state = new_state
	if last_state != -1 and states[last_state].exit != null:
		states[last_state].exit.call()
	if states[state].enter != null:
		states[state].enter.call()

func call_process(delta: float) -> void:
	if states[state].process != null:
		states[state].process.call(delta)

func add_state(idx: int, enter: Callable, exit: Callable, process: Callable):
	assert(idx == len(states))
	var inst = UIStateInstance.new()
	inst.enter = enter
	inst.exit = exit
	inst.process = process
	states.push_back(inst)

func add_state_reflect(idx: int, obj: Node, suffix: String):
	add_state(
		idx,
		Callable(obj, "enter_state_%s" % suffix),
		Callable(obj, "exit_state_%s" % suffix),
		Callable(obj, "process_state_%s" % suffix)
	)

func get_state() -> int:
	return state

func get_last_state() -> int:
	return last_state
