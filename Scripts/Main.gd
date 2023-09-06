extends Node2D

# shortcuts for node controls
onready var join_button = $SideUI/JoinButton
onready var host_button = $SideUI/HostButton
onready var ip_popup = $SideUI/JoinButton/IpPopup
onready var ip_entry = $SideUI/JoinButton/IpPopup/LineEdit
onready var leave_button = $SideUI/LeaveButton

var ip_address = Network.DEFAULT_IP

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func _player_connected(id):
	# Both clients call this method when a player joins, not when hosts
	Globals.otherPlayerId = id
	print(id)
	# Load gameboard
	var board = preload("res://Scenes/Board.tscn").instance()
	get_tree().get_root().add_child(board)
	# 

func _player_disconnected(id):
	print("Player left")

func _on_HostButton_pressed():
	print("Now hosting")
	var host = NetworkedMultiplayerENet.new()
	ip_address = IP.get_local_addresses()[1]
	print(ip_address)
	host.set_bind_ip(ip_address)
	var res = host.create_server(4242, 2)
	if res != OK:
		# put this in chat_history
		print("Error creating server")
		return
	# Hide buttons and connect to network, replace host button with leave
	join_button.hide()
	host_button.disabled = true
	leave_button.show()
	get_tree().network_peer = host
	# Display IP to send to other player
	$SideUI/IdLabel.text = ip_address


func _on_JoinButton_pressed():
	# Popup box for entering IP to connect
	ip_popup.popup()
	# Wait for user input
	yield(ip_popup,"confirmed")
	
	# Create client object and set network peer to it
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,4242)
	get_tree().network_peer = client
	# replace host button with disconnect
	host_button.hide()
	leave_button.show()
	# disable join button
	join_button.disabled = true
	

func _on_IpPopup_confirmed():
	var ip_entered = ip_entry.text
	if ip_entered:
		# Change the ip_address to what is entered
		ip_address = ip_entered


func _on_LeaveButton_pressed():
	# First identify if host or client
	var is_host = get_tree().is_network_server()
	# Disconnect
	get_tree().set_network_peer(null)
	# Reset button states to menu defaults
	leave_button.hide()
	if is_host:
		host_button.disabled = false
		join_button.show()
	else:
		join_button.disabled = false
		host_button.show()
