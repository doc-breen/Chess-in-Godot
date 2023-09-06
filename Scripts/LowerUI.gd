extends Control

onready var chatbox = $Chatbox
onready var chat_history = $ChatHistory


func _ready():
	pass


func _on_Chatbox_text_entered(new_text):
	var msg = new_text + "\n"
	chat_history.text += msg
	# Step 1, check that player is connected to a server
	if get_tree().get_network_peer():
		var id = get_tree().get_network_unique_id()
		print(id)
		# Step 2, send message to server/client
		rpc("receive_chat",id,msg)
		
	# Clear chatbox
	chatbox.text = ''


remote func receive_chat(id,msg):
	# Take msg and display locally
	chat_history.text += str(id) + msg
