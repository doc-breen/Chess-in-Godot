extends Control

var hotseat_scene = preload("res://Scenes/LocalMain.tscn")

func _on_HotseatButton_pressed():
	# Change scene to local interface, no chat, just turn tracking
	get_tree().change_scene_to(hotseat_scene)
	

func _on_AIButton_pressed():
	# Local interface where blue is controlled by AI
	pass # Replace with function body.


func _on_P2PButton_pressed():
	# Full networking interface with chat
	pass # Replace with function body.
