# Adapted from https://github.com/VolodyaKEK/godot-immediate-gui

class_name ELEGui
extends Control

@export var renderer: NodePath

var boxes: Array[Control] = [];
var used: Array[Control] = [];
var notused: Array[Control] = [];
var layout := true;
var _layout := VBoxContainer.new();

var _last_control;

var _default = {
	GUIControl:{
		"size_flags_horizontal":0,
		"size_flags_vertical":0,
	},
	GUIBaseButton:{
		"action_mode":BaseButton.ACTION_MODE_BUTTON_PRESS,
		"mouse_default_cursor_shape":CURSOR_POINTING_HAND,
	},
	GUIPickColor:{
		"rect_min_size":Vector2(20, 20),
	},
	GUITextureRect:{
		"expand_mode":TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	},
	GUITextEdit:{
		"wrap_mode":TextEdit.LINE_WRAPPING_BOUNDARY
	}
};
var property = {};

func clear_default():
	_default.clear();
# warning-ignore:shadowed_variable
func add_default(type, prop, value):
	var props = _default.get(type);
	if props == null:
		props = {};
		_default[type] = props;
	props[prop] = value;
# warning-ignore:shadowed_variable
func remove_default(type, prop=null):
	var props = _default.get(type);
	assert(props != null, str("There is no default values for type \"", type, "\""));
	if prop == null:
		_default.erase(type);
		return;
	var has_property = props.has(prop);
	assert(has_property, str("Can't remove property \"", prop, "\" from type \"", type, "\", property not set"));
	if has_property:
		props.erase(prop);

func _init():
	mouse_filter = MOUSE_FILTER_IGNORE;
	_layout.mouse_filter = MOUSE_FILTER_IGNORE;

func _ready():
	add_child(_layout);
	set_anchors_and_offsets_preset(PRESET_FULL_RECT);
	_layout.set_anchors_and_offsets_preset(PRESET_FULL_RECT);

func _process(delta):
	get_node(renderer).callv("_%s_gui" % name, [self, delta]);
	
	#move_to_front();
	layout = true;
	assert(boxes.size() == 0, "Not all containers are closed. Use GUI.end() to close containers.");
	boxes.clear();
	
	for c in notused:
		c.queue_free();
	notused.clear();
	
	var t = notused;
	notused = used;
	used = t;

func printvar(node, v):
	label(str(node.name, " ", "[", node.get_instance_id(), "] ", v, ": ", node.get(v)));

func _get_control(type, text=null):
	var _c: Control;
	for c in notused:
		if c.get_script() == type:
			_c = c;
			c.base.revert();
			notused.erase(c);
			break;
	if _c == null:
		_c = type.new();
	used.append(_c);
	@warning_ignore("incompatible_ternary")
	_reparent(_c, (_layout if layout else self) if boxes.size() == 0 else boxes[-1]);
	if text != null:
		_c.text = str(text);
	
	#_c.size = Vector2();
	
	for type2 in _default.keys():
		if _c.get_script() == type2:
			var defs = _default[type2];
			for p in defs.keys():
				_c.base.set_property(p, defs[p]);
	for p in property.keys():
		_c.base.set_property(p, property[p]);
	property.clear();
	
	_last_control = _c;
	return _c;
func _reparent(node:Node, new_parent:Node):
	var p = node.get_parent();
	if p == new_parent:
		node.move_to_front();
		return;
	if p != null:
		p.remove_child(node);
	if new_parent != null:
		new_parent.add_child(node);

func _toggle(type, text, state) -> bool:
	var b = _get_control(type, text);
	b.button_pressed = !state if b.base.get_changed() else state;
	return b.button_pressed;

func label(text) -> void:
	_get_control(GUILabel, text);
func wrapped_label(text, color=null) -> void:
	var l: GUILabel = _get_control(GUILabel, text)
	l.base.set_property("autowrap_mode", TextServer.AUTOWRAP_WORD_SMART)
	if color != null:
		l.base.set_property("theme_override_colors/font_color", color)
func texturerect(texture: Texture2D, minheight=null, fitheight:=false, full:=false) -> void:
	var _c = _get_control(GUITextureRect)
	if _c.texture != texture:
		_c.texture = texture
	if full:
		_c.base.set_property("expand_mode", TextureRect.EXPAND_KEEP_SIZE)
	elif fitheight:
		_c.base.set_property("expand_mode", TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL)
	else:
		_c.base.set_property("expand_mode", TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	if minheight:
		var sz = _c.custom_minimum_size
		sz.y = minheight
		_c.base.set_property("custom_minimum_size", sz)
func texturerect_full(texture: Texture2D):
	texturerect(texture, null, false, true)
func button(text, disabled:=false) -> bool:
	var b: GUIButton = _get_control(GUIButton, text)
	b.disabled = disabled
	return b.base.get_changed() and not disabled;
func buttonpress(text) -> bool:
	var b = _get_control(GUIButton, text);
	b.base.get_changed();
	return b.pressed;

func toggle(text, state:bool) -> bool:
	return _toggle(GUIToggle, text, state);
func checkbox(text, state:bool) -> bool:
	return _toggle(GUICheckBox, text, state);
func checkbutton(text, state:bool) -> bool:
	return _toggle(GUICheckButton, text, state);

func options(selected:int, opts:Array) -> int:
	var b = _get_control(GUIOptions);
	b.set_options(opts);
	if !b.base.get_changed():
		b.selected = selected;
	return b.selected;

func pickcolor(color:Color, edit_alpha:bool=true) -> Color:
	var c = _get_control(GUIPickColor);
	c.edit_alpha = edit_alpha;
	c.get_popup().rect_global_position = c.rect_global_position + Vector2(0, c.rect_size.y);
	if !c.base.get_changed():
		c.color = color;
	return c.color;
func progress(value:float, percent_visible:bool=true) -> void:
	var c = _get_control(GUIProgress);
	c.percent_visible = percent_visible;
	c.min_value = 0;
	c.max_value = 100;
	c.value = value*100;
func spin(value, min_value, max_value, step=null, allow_more:=false, allow_less:=false) -> float:
	var c: GUISpin = _get_control(GUISpin);
	c.min_value = min_value;
	c.max_value = max_value;
	c.step = (1.0 if value is int else 0.001) if step == null else step;
	c.allow_greater = allow_more
	c.allow_lesser = allow_less
	if !c.base.get_changed() && c.value != value:
		c.value = value;
	return c.value;
func line(text:String) -> String:
	var l = _get_control(GUILine);
	if !l.base.get_changed() && l.text != text:
		l.text = text;
	return l.text;
func textedit(text:String) -> String:
	var l = _get_control(GUITextEdit);
	if !l.base.get_changed() && l.text != text:
		l.text = text;
	return l.text;

func _get_box(type):
	var box = _get_control(type);
	boxes.append(box);
	return box;
func control() -> bool:
	_get_box(GUIControl);
	return true;
func hbox(separation=null) -> bool:
	var box = _get_box(GUIHBox);
	box.set("custom_constants/separation", separation);
	return true;
func vbox(separation=null) -> bool:
	var box = _get_box(GUIVBox);
	box.set("custom_constants/separation", separation);
	return true;
func grid(columns:int, vseparation=null, hseparation=null) -> bool:
	var box = _get_box(GUIGrid);
	box.columns = columns;
	box.set("custom_constants/vseparation", vseparation);
	box.set("custom_constants/hseparation", hseparation);
	return true;
func panel() -> bool:
	_get_box(GUIPanel);
	return true;
func margin(left:int=0, top:int=0, right:int=0, bottom:int=0) -> bool:
	var box = _get_box(GUIMargin);
	box.set("custom_constants/margin_left", left);
	box.set("custom_constants/margin_top", top);
	box.set("custom_constants/margin_right", right);
	box.set("custom_constants/margin_bottom", bottom);
	return true;
func center() -> bool:
	_get_box(GUICenter);
	return true;
func scroll() -> bool:
	_get_box(GUIScroll);
	return true;
func hflow() -> bool:
	_get_box(GUIHFlow)
	return true
func end() -> void:
	boxes.pop_back();
func use_as_box() -> void:
	boxes.append(used[-1])
func expand_vert() -> void:
	used[-1].base.set_property("size_flags_vertical", Control.SIZE_EXPAND_FILL)
func expand_horiz() -> void:
	used[-1].base.set_property("size_flags_horizontal", Control.SIZE_EXPAND_FILL)
func expand() -> void:
	expand_vert()
	expand_horiz()
func min_size(wid=null, hei=null) -> void:
	var ms = used[-1].custom_minimum_size
	if wid:
		ms.x = wid
	if hei:
		ms.y = hei
	used[-1].base.set_property("custom_minimum_size", ms)
func fullrect():
	used[-1].set_anchors_and_offsets_preset(PRESET_FULL_RECT);
func text_centered():
	var l: GUILabel = used[-1]
	l.base.set_property("horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER)


class GUIControl extends Control:
	var base = GUIBase.new(self);
class GUIVBox extends VBoxContainer:
	var base = GUIBase.new(self);
class GUIHBox extends HBoxContainer:
	var base = GUIBase.new(self);
class GUIGrid extends GridContainer:
	var base = GUIBase.new(self);
class GUIPanel extends PanelContainer:
	var base = GUIBase.new(self);
class GUIMargin extends MarginContainer:
	var base = GUIBase.new(self);
class GUICenter extends CenterContainer:
	var base = GUIBase.new(self);
class GUIScroll extends ScrollContainer:
	var base = GUIBase.new(self);
class GUIHFlow extends HFlowContainer:
	var base = GUIBase.new(self)

class GUILabel extends Label:
	var base = GUIBase.new(self);
class GUITextureRect extends TextureRect:
	var base = GUIBase.new(self)
class GUIBaseButton extends Button:
	var base = GUIBase.new(self, "pressed");
class GUIButton extends GUIBaseButton:
	pass
class GUIToggle extends GUIBaseButton:
	func _init():
		toggle_mode = true;
class GUICheckBox extends CheckBox:
	var base = GUIBase.new(self, "pressed");
class GUICheckButton extends CheckButton:
	var base = GUIBase.new(self, "pressed");
class GUIOptions extends OptionButton:
	var base = GUIBase.new(self, "item_selected");
	var options = [];
	func set_options(_options):
		if options != _options:
			options = _options;
			clear();
			for txt in options:
				add_item(str(txt));
class GUILine extends LineEdit:
	var base = GUIBase.new(self, "text_changed");
class GUITextEdit extends TextEdit:
	var base = GUIBase.new(self, "text_changed")
class GUIPickColor extends ColorPickerButton:
	var base = GUIBase.new(self, "color_changed");
class GUIProgress extends ProgressBar:
	var base = GUIBase.new(self);
class GUISpin extends SpinBox:
	var base = GUIBase.new(self, "value_changed");

class GUIBase:
	var node;
	var changed:bool;
	func _changed(_v=null):
		changed = true;
	func get_changed():
		if changed:
			changed = false;
			return true;
		return false;
	var defs = {};
	var edited = [];
	func _init(_node, _signal=null):
		node = _node;
		if _signal != null:
			node.get(_signal).connect(_changed)
	func set_property(p, v):
		if !defs.has(p):
			defs[p] = node.get(p);
		edited.append(p);
		node.set(p, v);
	func revert():
		for p in edited:
			var def = defs.get(p);
			if node.get(p) != def:
				node.set(p, def);
		edited.clear();
