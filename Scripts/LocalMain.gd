extends Node2D
# This script contains checkCheck

# board_state is a 2D array so pieces can easily check if tile
# is occupied. 
var board_state = [[]]

var time_string: String

# Set node paths for common items
onready var board = $Board
onready var side_ui = $SideUI
# Paths for Castling GUI
onready var castle_ui = $LowerUI/CastlingUI
onready var cLeft = $LowerUI/CastlingUI/CastleLeft
onready var cRight = $LowerUI/CastlingUI/CastleRight
# Paths for castling
onready var wking = $Board/King2
onready var bking = $Board/King
onready var wrook_L = $Board/Rook3
onready var brook_L = $Board/Rook
onready var wrook_R = $Board/Rook4
onready var brook_R = $Board/Rook2
onready var clock = $SideUI/VBoxContainer/Panel/ClockDisplay
onready var team_label = $SideUI/VBoxContainer/TeamLabel
var clock_start = 0
const wqueen = preload("res://Scenes/WhiteQueen.tscn")
const bqueen = preload("res://Scenes/BlueQueen.tscn")
const wknight = preload("res://Scenes/WhiteKnight.tscn")
const bknight = preload("res://Scenes/BlueKnight.tscn")
const wrook = preload("res://Scenes/WhiteRook.tscn")
const brook = preload("res://Scenes/BlueRook.tscn")

func _ready():
	# warning-ignore:return_value_discarded
	Network.connect("update_board",self,"_on_update_board")
	# warning-ignore:return_value_discarded
	Network.connect("team_change",self,"_on_team_change")
	# By the time the main node readies, all other nodes should be added
	# so that this loop to disable blue pieces ensures that white goes first
	for p in get_tree().get_nodes_in_group("blue"):
		p.piece.input_pickable = false
	
# Need process to check turn and when to display Castling UI
func _process(_delta):
	# warning-ignore:integer_division
	var tim = Time.get_ticks_msec()/1000 - clock_start
	time_string = '%02d : %02d : %02d'
	var mn = floor(tim/60)
	var hr = floor(mn/60)
	clock.text = time_string % [hr,mn,tim%60]
	
	if Network.white_team:
		wking.castling_test()
		if wking.can_castle:
			_show_castling()
	else:
		bking.castling_test()
		if bking.can_castle:
			_show_castling()
	
	if !wking.can_castle and !bking.can_castle:
		castle_ui.visible = false


func space_is_empty(tile,test_state=board_state) -> bool:
	# This function will be called by pieces when checking
	# for legal spaces to highlight. tile is a Vector2
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	if (test_state[tile.y][tile.x] == Globals.empty):
		return true
	else: 
		return false

# team_color should be the color of the enemy team
func space_is_enemy(tile,team_color,test_state=board_state) -> bool:
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	# This array stores the values for team enums
	var team = []
	if team_color == 'white':
		team = [1,2,3,4,5,6]
	if team_color == 'blue':
		team = [7,8,9,10,11,12]
	
	if test_state[tile.y][tile.x] in team:
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
		n.find_attacks(board_state)
		# Each piece scene has a var attacks which
		# stores the tiles that piece can "see"
		if tile in n.attacks:
			# Check
			return true
		# Return false at the end of the for loop
		if count == len(team_nodes):
			return false

func test_check(tile,team_color):
	# Because checkCheck needs to be used on an imaginary board state
	# This function should eventually replace checkCheck completely.
	
	# First copy the actual board_state
	var imaginary_state = board_state
	var team_nodes = get_tree().get_nodes_in_group(team_color)
	var count = 0
	# Remove piece from test state
	imaginary_state[tile.y][tile.x] = Globals.empty
	# Get location of the appropriate king
	var king
	if team_color == 'white':
		king = bking
	elif team_color == 'blue':
		king = wking
	
	for n in team_nodes:
		count += 1
		n.find_attacks(imaginary_state)
		if king.current_tile in n.attacks:
			return true
		if count == len(team_nodes):
			return false
		

# Capture goes here because it is easier to manage
func _on_Piece_capture(area) -> void:
	# Get the parent of the area, because the Piece class is 
	# always a child node
	area.get_parent().queue_free()

# Update the board_state
func _on_update_board(old_tile, new_tile, piece_id) -> void:
	# clear old space
	board_state[old_tile.y][old_tile.x] = Globals.empty
	# Place new piece
	board_state[new_tile.y][new_tile.x] = piece_id

func _show_castling():
	var btn_clr: Color
	if Network.white_team:
		btn_clr = Color("c2c6e7")
	else:
		btn_clr = Color("7fb9e7")
	castle_ui.visible = true
	castle_ui.modulate = btn_clr
	

func _on_Board_tree_entered():
	# Initialize board
	# Has to be done before ready because other nodes
	# call board_state when they ready
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

	if Network.white_team:
		king = wking
		rook = wrook_L
		king_tile = Vector2(4,7)
		rook_tile = Vector2(0,7)
		king_id = Globals.wK
		rook_id = Globals.wR
		tiles_in_route.append(Vector2(3,7))
		tiles_in_route.append(Vector2(2,7))
		enemy = 'blue'
		
	else:
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
		king.has_moved = true
		rook.has_moved = true
		# Hide UI
		cLeft.visible = false
		castle_ui.visible = false
		Network.pass_turn()


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
	
	if Network.white_team:
		king = wking
		rook = wrook_R
		king_tile = Vector2(4,7)
		rook_tile = Vector2(7,7)
		king_id = Globals.wK
		rook_id = Globals.wR
		tiles_in_route.append(Vector2(5,7))
		tiles_in_route.append(Vector2(6,7))
		enemy = 'blue'
	
	else:
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
			print("King cannot move through check")
			return
		okay = true
	
	if okay:
		# Move King to right
		_on_update_board(king_tile,king_tile+Vector2(2,0),king_id)
		Network.animate_move(king_tile,king_tile+Vector2(2,0),king)
	
		# Move Rook to left
		_on_update_board(rook_tile,rook_tile-Vector2(2,0),rook_id)
		Network.animate_move(rook_tile,rook_tile-Vector2(2,0),rook)
		
		king.can_castle = false
		king.has_moved = true
		rook.has_moved = true
		# Hide UI
		cRight.visible = false
		castle_ui.visible = false
		Network.pass_turn()
	

func _on_cLeft_received():
	if Network.white_team and !wrook_L.has_moved:
		cLeft.visible = true
	elif !Network.white_team and !brook_L.has_moved:
		cLeft.visible = true
	else: cLeft.visible = false


func _on_cRight_received():
	if Network.white_team and !wrook_R.has_moved:
		cRight.visible = true
	elif !Network.white_team and !brook_R.has_moved:
		cRight.visible = true
	else: cRight.visible = false

func _on_team_change():
	# If castling was possible but not done, need to hide the UI
	cLeft.visible = false
	cRight.visible = false
	castle_ui.visible = false
	# Lock out pieces by toggling input_pickable in each piece's Piece
	# Note: value of white_team changes immediately before this call
	# This function is technically beginning of a turn, not end of one
	var king
	if Network.white_team:
		king = wking
		team_label.text = "    White"
		team_label.self_modulate = Color("ffffff")
		for p in get_tree().get_nodes_in_group("white"):
			p.piece.input_pickable = true
		for o in get_tree().get_nodes_in_group("blue"):
			o.piece.input_pickable = false
	else:
		king = bking
		team_label.text = "    Blue"
		team_label.self_modulate = Color("1f9ad6")
		for p in get_tree().get_nodes_in_group("blue"):
			p.piece.input_pickable = true
		for o in get_tree().get_nodes_in_group("white"):
			o.piece.input_pickable = false
	# If current team king is in check, alert
	king.on_team_test()
	

func _on_CheckAlert_received():
	side_ui.get_node("VBoxContainer/CheckAlertPopup").popup()
	

func _end_game(team_won):
	# Display which team wins and stop timer?
	$EndGamePopup/VBoxContainer/Label.text = team_won + ' wins!'
	$EndGamePopup.popup()
	yield(get_tree().create_timer(2),"timeout")
	$EndGamePopup/VBoxContainer/RestartButton.visible = true

func _on_Pawn_conversion(tile,team,pawn):
	# Temporarily just spawn a Queen because that's easy and no one picks
	# anything else anyway so fuck the illusion of choice
	var new_Q: Node2D
	var p_id: int
	if team == 'white':
		new_Q = wqueen.instance()
		p_id = Globals.wQ
	elif team == 'blue':
		new_Q = bqueen.instance()
		p_id = Globals.bQ
	var new_pos = Globals.tile_2_xy(tile)
	new_Q.position = new_pos
	# update board_state
	board_state[tile.y][tile.x] = p_id
	pawn.queue_free()
	board.add_child(new_Q)

# Reset clock time
func _on_ClockDisplay_ready():
	# warning-ignore:integer_division
	clock_start = Time.get_ticks_msec()/1000


func _on_ConcedeButton_pressed():
	var team_won: String
	if Network.white_team:
		team_won = 'Blue'
	else:
		team_won = 'White'
	_end_game(team_won)
	# Disable button
	side_ui.get_node("VBoxContainer/ConcedeButton").disabled = true
	


func _on_RestartButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	if !Network.white_team:
		Network.white_team = true
