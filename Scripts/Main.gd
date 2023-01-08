extends Node2D
# This script contains checkCheck, but needs to also run at end of turn

# board_state is a 2D array so pieces can easily check if tile
# is occupied. 
var board_state = [[]]
var current_player_turn:= 'white'

# Set node paths for common items
onready var board = $Board
onready var chat = $LowerUI/Chatbox
onready var chat_history = $LowerUI/ChatHistory
onready var chat_name = $LowerUI/ChatName
onready var ip_box = $SideUI/IPEdit
onready var host_btn = $SideUI/HostButton
onready var join_btn = $SideUI/JoinButton
onready var side_ui = $SideUI
# Paths for Castling GUI
onready var castle_gui = $LowerUI/CastlingUI
onready var cLeft = $LowerUI/CastlingUI/CastleLeft
onready var cRight = $LowerUI/CastlingUI/CastleRight
# Paths for castling
onready var wking = $Board/King2
onready var bking = $Board/King
onready var wrook_L = $Board/Rook3
onready var brook_L = $Board/Rook
onready var wrook_R = $Board/Rook4
onready var brook_R = $Board/Rook2

func _ready():
	# warning-ignore:return_value_discarded
	Network.connect("update_board",self,"_on_update_board")
	
# Need process to check turn and when to display Castling UI
func _process(_delta):
	
	# if team:
	# 	and if (!king.check) and (!king.has_moved):
	#		and if !rook.has_moved:
	# castle_gui.visible = true
	# else: castle_gui.visible = false
	pass

func space_is_empty(tile) -> bool:
	# This function will be called by pieces when checking
	# for legal spaces to highlight. tile is a Vector2
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	if (board_state[tile.y][tile.x] == Globals.empty):
		return true
	else: 
		return false

# team_color should be the color of the enemy team
func space_is_enemy(tile,team_color) -> bool:
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	# This array stores the values for team enums
	var team = []
	if team_color == 'white':
		team = [1,2,3,4,5,6]
	if team_color == 'blue':
		team = [7,8,9,10,11,12]
	
	if board_state[tile.y][tile.x] in team:
		return true
	else:
		return false

# Check checker for checking if in check
func checkCheck(tile,team_color):
	# team_color is the team to check if it can attack
	var team_nodes = get_tree().get_nodes_in_group(team_color)
	var count = 0
	for n in team_nodes:
		count += 1
		# Each piece scene has a var attacks which
		# stores the tiles that piece can "see"
		if tile in n.attacks:
			# Check
			return true
		# Return false at the end of the for loop
		if count == len(team_nodes):
			return false

# Capture goes here because it is easier to manage
func _on_Piece_capture(area) -> void:
	area.get_parent().queue_free()

# Update the board_state
func _on_update_board(old_tile, new_tile, piece_id) -> void:
	# clear old space
	board_state[old_tile.y][old_tile.x] = Globals.empty
	# Place new piece
	board_state[new_tile.y][new_tile.x] = piece_id


func _on_Board_tree_entered():
	# Initialize board
	# Has to be done before ready because other nodes
	# call board_state
	board_state[0] = [Globals.bR,Globals.bN,Globals.bB,Globals.bQ,
					Globals.bK,Globals.bB,Globals.bN,Globals.bR]
	board_state.append([])
	board_state[1] =[Globals.bP,Globals.bP,Globals.bP,Globals.bP,
					Globals.bP,Globals.bP,Globals.bP,Globals.bP] 
	for row in range(2,6):
		board_state.append([])
		board_state[row] = [Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty]
	board_state.append([])
	board_state[6] = [Globals.wP,Globals.wP,Globals.wP,Globals.wP,
					Globals.wP,Globals.wP,Globals.wP,Globals.wP]
	board_state.append([])
	board_state[7] = [Globals.wR,Globals.wN,Globals.wB,Globals.wQ,
					Globals.wK,Globals.wB,Globals.wN,Globals.wR]


func _on_HostButton_pressed():
	chat.text = ""
	Network.host()
	#var ip_address = IP.get_local_addresses()[1]
	var ip_address = Network.external_ip
	ip_box.text = ip_address
	# Disable buttons while hosting
	#host_btn.disabled = true
	#join_btn.disabled = true
	# White team is host

func _on_JoinButton_pressed():
	# Always clear Chatbox whenever pressing a button
	chat.text = ""
	var ip_address = ip_box.text
	# Need a condition for server being hosted
	if get_tree().get_network_peer():
		Network.self_data.name = chat_name.text
		Network.connect_to_server(ip_address)
		chat.text = "Connected to " + ip_address
		# Disable buttons if connected to server
		#host_btn.disabled = true
		#join_btn.disabled = true
	else:
		chat.text = "No server exists! \n Check IP and try again, or press HOST"
	
	# Set Join as blue team
	#var team = get_tree().get_nodes_in_group('BlueTeam')
	#for n in team:
	#	var SelfID = get_tree().get_network_unique_id()
	#	Network.set_network_master(SelfID)


func _on_CastleLeft_pressed():
	# first get team to affect
	var king_tile: Vector2
	var rook_tile: Vector2
	var king: Object
	var rook: Object
	var king_id: int
	var rook_id: int
# warning-ignore:unassigned_variable
	var tiles_in_route: PoolVector2Array
	var enemy: String
	var okay: bool
	### Need to get path to the actual pieces in animate_move

	if current_player_turn == 'white':
		king = wking
		rook = wrook_L
		king_tile = Vector2(4,7)
		rook_tile = Vector2(0,7)
		king_id = Globals.wK
		rook_id = Globals.wR
		tiles_in_route.append(Vector2(3,7))
		tiles_in_route.append(Vector2(2,7))
		enemy = 'blue'
		
	elif current_player_turn == 'blue':
		king = bking
		rook = brook_L
		king_tile = Vector2(4,0)
		rook_tile = Vector2(0,0)
		king_id = Globals.bK
		rook_id = Globals.bR
		tiles_in_route.append(Vector2(3,0))
		tiles_in_route.append(Vector2(2,0))
		enemy = 'white'
	
	# Test for check
	for timmy in tiles_in_route:
		if checkCheck(timmy,enemy):
			okay = false
			break
		okay = true

	if okay:
		# Move King to left
		_on_update_board(king_tile,king_tile-Vector2(2,0),king_id)
		Network.animate_move(king_tile,king_tile-Vector2(2,0),king)
	
		# Move Rook to right
		_on_update_board(rook_tile,rook_tile+Vector2(3,0),rook_id)
		Network.animate_move(rook_tile,rook_tile+Vector2(3,0),rook)
		
		# Last step, make sure the king cannot castle again
		king.can_castle = false


func _on_CastleRight_pressed():
	var king_tile: Vector2
	var rook_tile: Vector2
	var king: Object
	var rook: Object
	var king_id: int
	var rook_id: int
# warning-ignore:unassigned_variable
	var tiles_in_route: PoolVector2Array
	var enemy: String
	var okay: bool
	
	if current_player_turn == 'white':
		king = wking
		rook = wrook_R
		king_tile = Vector2(4,7)
		rook_tile = Vector2(7,7)
		king_id = Globals.wK
		rook_id = Globals.wR
		tiles_in_route.append(Vector2(5,7))
		tiles_in_route.append(Vector2(6,7))
		enemy = 'blue'
		
	elif current_player_turn == 'blue':
		king = bking
		rook = brook_R
		king_tile = Vector2(4,0)
		rook_tile = Vector2(7,0)
		king_id = Globals.bK
		rook_id = Globals.bR
		tiles_in_route.append(Vector2(5,0))
		tiles_in_route.append(Vector2(6,0))
		enemy = 'white'
	# Test for check
	for timmy in tiles_in_route:
		if checkCheck(timmy,enemy):
			okay = false
			break
		okay = true
	
	if okay:
		# Move King to right
		_on_update_board(king_tile,king_tile+Vector2(2,0),king_id)
		Network.animate_move(king_tile,king_tile+Vector2(2,0),king)
	
		# Move Rook to left
		_on_update_board(rook_tile,rook_tile-Vector2(2,0),rook_id)
		Network.animate_move(rook_tile,rook_tile-Vector2(2,0),rook)
		
		king.can_castle = false

func _on_NameEdit_text_entered(new_text):
	# This merely updates the username
	chat_name.text = new_text
	

func _on_Chatbox_text_entered(new_text):
	# Step 0: add text to local ChatHistory and clear Chatbox
	var message = new_text + '\n'
	
	# Step 1, check that player is connected to a server
	if get_tree().get_network_peer():
		var id = get_tree().get_network_unique_id()
		print(id)
		# Step 2, send message to server/client
		rpc("receive_chat",id,message)
	
	chat.text = ''

remotesync func receive_chat(id,message):
	chat_history.text += str(id) + ':' + message
