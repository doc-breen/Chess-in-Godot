extends Node2D

onready var mouselight:= $Light2D
const game_scene = preload("res://Scenes/Board.tscn")

func _ready():
	pass


func _process(delta):
	if InputEventMouseMotion:
		_followMouse(delta)
	else:
		_projectile(delta)


# Track mouse movement
func _followMouse(delta):
	var mouse_pos = get_global_mouse_position()
	mouselight.position = lerp(mouselight.position,mouse_pos,55*delta)


# Motion of light when not selected
func _projectile(delta):
	pass


func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(game_scene)
