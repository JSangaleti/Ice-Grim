extends RefCounted

static func setup() -> void:
	_bind("left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_bind("right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_bind("jump", [KEY_W, KEY_UP], JOY_BUTTON_A)
	_bind("crouch", [KEY_S, KEY_DOWN], JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_bind("run", [KEY_SHIFT], JOY_BUTTON_X)
	_bind("dash", [KEY_SPACE], JOY_BUTTON_B)
	_bind("pause", [KEY_ESCAPE], JOY_BUTTON_START)
	_bind("restart", [KEY_R], JOY_BUTTON_BACK)
	_add_keys("ui_up", [KEY_W])
	_add_keys("ui_down", [KEY_S])

static func _add_keys(action: String, keys: Array) -> void:
	for code in keys:
		var event := InputEventKey.new()
		event.physical_keycode = code
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)

static func _bind(action: String, keys: Array, button: int, axis: int = -1, value: float = 0.0) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action, 0.25)
	_add_keys(action, keys)
	var press := InputEventJoypadButton.new()
	press.button_index = button
	InputMap.action_add_event(action, press)
	if axis >= 0:
		var motion := InputEventJoypadMotion.new()
		motion.axis = axis
		motion.axis_value = value
		InputMap.action_add_event(action, motion)
