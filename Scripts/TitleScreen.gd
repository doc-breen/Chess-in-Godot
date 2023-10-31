extends Node2D

onready var mouselight:= $Light2D
const game_scene = preload("res://Scenes/Board.tscn")
const SCREEN_WIDTH = 840
const SCREEN_HEIGHT = 600
var mouse_active: = false
# For light
var speed: = 313
var vel = Vector2(1,1)
onready var light_timer:= $Light2D/Timer

func _ready():
	pass


func _process(delta):
	if mouse_active:
		followMouse(delta)
	else:
		projectile(delta)
	if light_timer.time_left < 0.1:
		mouse_active = false

func _input(event):
	if event is InputEventMouseMotion:
		mouse_active = true
		light_timer.start()

# Track mouse movement
func followMouse(delta):
	var mouse_pos = get_global_mouse_position()
	mouselight.position = lerp(mouselight.position,mouse_pos,55*delta)


# Motion of light when not selected
func projectile(delta):
	var l_pos = mouselight.position
	var delta_p = speed*vel*delta
	if (l_pos+delta_p).x < 0 or (l_pos+delta_p).x >= SCREEN_WIDTH:
		vel.x *= -1
	if (l_pos+delta_p).y < 0 or (l_pos+delta_p).y >= SCREEN_HEIGHT:
		vel.y *= -1
	mouselight.position += speed*vel*delta


func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(game_scene)
