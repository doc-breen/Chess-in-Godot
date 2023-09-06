class_name InputArea
extends Area2D


## Snap back behavior on release option
export var snap_on_release = true
var home_position: Vector2

## This section is drag and drop
var selected = false
# get_parent because this class always attaches to other nodes to move them
onready var parent_node = self.get_parent()

## These signals are for connecting to other scripts
signal is_selected
signal is_dropped



func _ready():
	home_position = parent_node.position
	
	# warning-ignore:return_value_discarded
	connect("input_event",self,"_on_InputArea_input_event")
# warning-ignore:return_value_discarded
	connect("is_selected",parent_node,"_on_InputArea_is_selected")
# warning-ignore:return_value_discarded
	connect("is_dropped",parent_node,"_on_InputArea_released")

# Where the magic happens
func _process(delta):
	if selected:
		_followMouse(delta)
	elif snap_on_release == true:
		# When released, return to home tile
		parent_node.position = lerp(parent_node.position,home_position,22*delta)


# Track mouse movement
func _followMouse(delta):
	var mouse_pos = get_global_mouse_position()
	parent_node.position = lerp(parent_node.position,mouse_pos,77*delta)


# This event function is to handle releasing button
func _input(event):
	# Needs the echo check to prevent accidental double calls
	if event is InputEventMouseButton:# and not event.is_echo():
		# Need a check for selected because otherwise ALL pieces
		# will trigger when dropped.
		if selected:
			selected = false
			emit_signal("is_dropped")


# This is the pickup behavior.  Must be connected to self
func _on_InputArea_input_event(_viewport, _event, _shape_idx):
	# Rapid clicks cause extra events
	# Include !selected to make sure it only acts on the first one
	if Input.is_action_just_pressed("click") and !selected:
		selected = true
		emit_signal("is_selected")
	
