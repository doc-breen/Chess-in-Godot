extends Node2D

# Board needs to handle its own state changes like showing tiles
# But also handles game_state changes like check
var board_state = []
onready var wking = $TileMap/WhiteKing
onready var bking = $TileMap/BlueKing
onready var wrook_Q = $TileMap/WhiteRook 
onready var brook_Q = $TileMap/BlueRook2
onready var wrook_K = $TileMap/WhiteRook2
onready var brook_K = $TileMap/BlueRook
onready var Tiles = $TileMap
signal end_game
var tile_states = []
var attacker_can_be_captured: bool
var check_can_be_blocked: bool
enum TileColor {WHITE,BLUE,GREEN,ORANGE,RED,BLACK}
# This one is for converting pawns
var swapping_pawn: Piece
# Piece preloads
const wqueen = preload("res://Scenes/WhiteQueen.tscn")
const bqueen = preload("res://Scenes/BlueQueen.tscn")
const wknight = preload("res://Scenes/WhiteKnight.tscn")
const bknight = preload("res://Scenes/BlueKnight.tscn")
const wrook = preload("res://Scenes/WhiteRook.tscn")
const brook = preload("res://Scenes/BlueRook.tscn")
const wbish = preload("res://Scenes/WhiteBishop.tscn")
const bbish = preload("res://Scenes/BlueBishop.tscn")
onready var check_menu = $Control/CheckBox
onready var castle_ui = $BottomUI
onready var qside_btn = $BottomUI/CastleQueen
onready var kside_btn = $BottomUI/CastleKing
onready var turn_btn = $Control/VBoxContainer/Button


func _ready():
	# warning-ignore:return_value_discarded
	Network.connect("team_change",self,"_on_team_changed")
	# warning-ignore:return_value_discarded
	connect("end_game",Network,"on_game_over")
	# Set initial board_state from scene tree
	for nod in get_tree().get_nodes_in_group('Pieces'):
		board_state[nod.current_tile.y][nod.current_tile.x] = nod.piece_id
	# Make sure to lock out blue pieces here
	_lock_pieces("blue")
	# warning-ignore:return_value_discarded
	Network.connect("update_board",self,"_on_board_updated")
	initialize_kings()
	


func initialize_kings():
	bking.get_legal_tiles()
	wking.get_legal_tiles()


func _process(_delta):
	if Network.white_team:
		turn_btn.text = "White turn"
	else:
		turn_btn.text = 'Blue turn'


# Done. Do not change.
func _lock_pieces(team:String='Pieces'):
	# Toggle off the input_pickable values for Piece on team
	for n in get_tree().get_nodes_in_group(team):
		n.pick_area.input_pickable = false
	


# Done. Do not change.
func _unlock_pieces(team:String):
	# Toggle on the input_pickable values for Piece on team
	for n in get_tree().get_nodes_in_group(team):
		n.pick_area.input_pickable = true


# Done.  Tests if given tile is in check for given board state
func test_check(tile:Vector2, state:=board_state):
	var enemy: String
	# first determine which team is active
	if Network.white_team:
		enemy = "blue"
	else:
		enemy = "white"
	
	var count:= 0
	var whole_team = get_tree().get_nodes_in_group(enemy)
	for nod in whole_team:
		nod.find_attacks(state)
		if tile in nod.attacks:
			return true
		else:
			count += 1
		
		if count == len(whole_team):
			# king not in check
			return false


# Some edge cases still fucked
func _test_checkmate():
	# Test if any legal moves exist
	var king
	if Network.white_team:
		king = wking
	else:
		king = bking
	king.get_legal_tiles()
	var p_set = get_tree().get_nodes_in_group(king.team)
	if len(king.legal_tiles) > 0:
		# king.legal_tiles is not allowed to be into check
		# so if it exists, then it's not checkmate
		print('king has moves available: ', king.legal_tiles)
		return false
	else:
		# Find attacking piece(s)
		var attacker = king.get_attacker()
		# If more than 2 pieces have king in check, then it's mate
		if attacker.size() == 1:
			var blocks = get_attacking_tiles(king, attacker[0])
			for t in p_set:
				if is_attacking(t,attacker[0].current_tile):
					# this is when the checking piece can be captured
					print('attacker can be captured')
					return false
				else:
					for b in blocks:
						if b in t.attacks:
							# this is when check can be blocked
							print('attacker can be blocked')
							return false
	# Alternative method?  Seems to intermittently break, not sure why.
		var c:= 0
		for p in p_set:
			p.find_attacks()
			p.get_legal_tiles(p.attacks)
			var filt_att = _filter_attacks(p.legal_tiles,p)
			if filt_att == []:
				c += 1
		if c == len(p_set):
			print('Checkmate')
			return true
	# If nothing else completes without returning false, then it's checkmate
	print('Checkmate')
	return true
	



# Done
func space_is_empty(tile:Vector2, state:= board_state) -> bool:
	if Globals.OoB_test(tile):
		# Out of bounds
		return false
	# Check if tile is unoccupied
	if state[tile.y][tile.x] == Globals.empty:
		return true
	else:
		return false


# Done?
func space_is_enemy(tile:Vector2, state:Array, team:String) -> bool:
	
	if Globals.OoB_test(tile):
		# Out of bounds
		return false
		
	var t_set = []
	if team == 'white':
		t_set = [1,2,3,4,5,6]
	else:
		t_set = [7,8,9,10,11,12]
	if state[tile.y][tile.x] in t_set:
		return true
	else:
		return false


# Done
func show_tiles(tile_list:Array):
	# For each tile in array, store the old tile state and change it
	for tile in tile_list:
		tile_states.append(Tiles.get_cellv(tile))
		# Piece class will refer to tile color when determining if move is legal
		Tiles.set_cellv(tile,TileColor.GREEN)


# Done?
func _on_tiles_off_signal(tile_list:Array) -> void:
	# Take previously stored array and change tile states back
	if tile_states:
		for t in range(0,len(tile_list)):
			if Tiles.get_cellv(tile_list[t]) == TileColor.GREEN:
				Tiles.set_cellv(tile_list[t],tile_states[t])
	# Clear the states array
	tile_states = []
	


# Done. Do not change.
func move_test(tile:Vector2) -> bool:
	# Make sure tile is green
	if Tiles.get_cellv(tile) == TileColor.GREEN:
		return true
	else:
		return false


# Done, except maybe some edge cases
func castle_test(king: Piece) -> bool:
	var Qrook = wrook_Q if king.team == 'white' else brook_Q
	var Krook = wrook_K if king.team == 'white' else brook_K
	var left:= false
	var right:= false
	# Test king conditions
	if king.has_moved or king.has_castled or king.in_check or !king.never_checked:
		return false
	# Test rooks
	elif Qrook.has_moved and Krook.has_moved:
		return false
	else:
		# Test if spaces are empty
		var tiles_to_test = [Vector2(king.current_tile.x-1,king.current_tile.y),
						Vector2(king.current_tile.x-2,king.current_tile.y),
						Vector2(king.current_tile.x-3,king.current_tile.y)]
		var okay:= 0
		for t in tiles_to_test:
			if space_is_empty(t) and !test_check(t):
				okay += 1
			else:
				break
		if okay == len(tiles_to_test):
			# Queenside castle okay
			qside_btn.visible = true
			left = true
		else: qside_btn.visible = false
		# Repeat for kingside
		tiles_to_test = [Vector2(king.current_tile.x+1,king.current_tile.y),
						Vector2(king.current_tile.x+2,king.current_tile.y)]
		okay = 0
		for t in tiles_to_test:
			if space_is_empty(t) and !test_check(t):
				okay += 1
			else: break
		if okay == len(tiles_to_test):
			# Kingside castle okay
			kside_btn.visible = true
			right = true
		else: kside_btn.visible = false
		if left or right:
			return true
		else:
			return false

# Done.  Do not change.
func is_attacking(this_node:Piece, that_tile:Vector2) -> bool:
	this_node.find_attacks()
	if that_tile in this_node.attacks:
		return true
	else:
		return false


# Seems done
func get_attacking_tiles(king:Piece, attacker:Piece) -> Array:
	var tile_list = []
	var direc = king.current_tile - attacker.current_tile
	
	if direc.x == 0:
		# .x = 0 when pieces are same column
		if direc.y > 0:
			for d in range(1,direc.y-1):
				tile_list.append(king.current_tile + Vector2(0,d))
		elif direc.y < 0:
			for d in range(1,abs(direc.y)-1):
				tile_list.append(king.current_tile - Vector2(0,d))
	elif direc.y == 0:
		# .y = 0 when pieces are same row
		if direc.x > 0:
			for d in range(1,direc.x-1):
				tile_list.append(king.current_tile + Vector2(d,0))
		elif direc.x < 0:
			for d in range(1,abs(direc.x)-1):
				tile_list.append(king.current_tile - Vector2(-d,0))
	else:
		# diagonal or knight attack
		var D = direc.x + direc.y
		# D positive when attacker is NW of king
		if D > 0:
			for d in range(1,D/2-1):
				tile_list.append(king.current_tile + Vector2(d,d))
		# D negative when attacker is SE of king
		elif D < 0:
			for d in range(1,-D/2):
				tile_list.append(king.current_tile + Vector2(d,d))
		elif D == 0:
			# D = 0 when NE or SW of king
			if direc.x > direc.y:
				for d in range(1,direc.x-1):
					tile_list.append(king.current_tile + Vector2(d,-d))
			elif direc.y < direc.x:
				for d in range(1,direc.y -1):
					tile_list.append(king.current_tile + Vector2(-d,d))
	return tile_list


# This should correctly filter out moves which leave king in check
func _filter_attacks(att_list: Array, piece: Piece) -> Array:
	var safe_tiles:= []
	if piece.piece_id != Globals.wK and piece.piece_id != Globals.bK:
		# Take moveset and highlight ones which do not leave king in check
		var king: Piece
		if Network.white_team:
			king = wking
		else:
			king = bking
		# Create test state
		var test_state = board_state.duplicate(true)
		# Remove piece from test state
		test_state[piece.current_tile.y][piece.current_tile.x] = Globals.empty
		for t in att_list:
			var temp_id = test_state[t.y][t.x]
			test_state[t.y][t.x] = piece.piece_id
			if !test_check(king.current_tile, test_state):
				safe_tiles.append(t)
			# restore test state before resuming loop
			test_state[t.y][t.x] = temp_id
	else:
		safe_tiles = att_list
	
	return safe_tiles
	

# Done for local play
func _on_board_updated(old_tile:Vector2, new_tile:Vector2, piece_id:int):
	# Move the piece from old to new
	board_state[old_tile.y][old_tile.x] = Globals.empty
	board_state[new_tile.y][new_tile.x] = piece_id
	# In networked play, the other player must have move animated also
	# In player-vs-ai game, the AI move must be animated


# Seems done
func _on_attacks_received(attack_list:Array, piece:Piece):
	# Filter out moves which leave king in check
	var filtered_tiles = _filter_attacks(attack_list,piece)
	# After filtering, highlight the appropriate tiles
	piece.legal_tiles = filtered_tiles
	show_tiles(filtered_tiles)


# Possibly finished for local play
func _on_team_changed(team:bool):
	# This is the beginning of a turn.  This function must lock out pieces
	# It also must call the test for check.
	# Test for check
	var king: Piece
	var team_str: String
	if team:
		king = wking
		team_str = 'White'
	else:
		king = bking
		team_str = 'Blue'
	if test_check(king.current_tile, board_state):
		# Test for checkmate, too
		if _test_checkmate():
			emit_signal("end_game")
		else:
			# Notify check
			check_menu.get_child(0).text = team_str + ' king is in check!'
			check_menu.popup()
			king.in_check = true
			if king.never_checked:
				king.never_checked = false
	else:
		# Not in check, do nothing
		king.in_check = false
	
	# Change active team
	if team:
		# Lock out Blue
		_lock_pieces("blue")
		# Unlock White
		_unlock_pieces("white")
	else:
		# Lock out White
		_lock_pieces("white")
		# Unlock Blue
		_unlock_pieces("blue")
	
	# Display castling UI if necessary
	if castle_test(king):
		castle_ui.visible = true
	else:
		# In case it was still visible from last turn
		castle_ui.visible = false



# Done
func _on_Pawn_converted(pawn: Piece):
	swapping_pawn = pawn
	# Pause everything except for the popup.
	get_tree().paused = true
	# Popup display for choosing new piece
	$Control/PieceConversion.popup()
	


# Done
func _on_Board_tree_entered():
	# Set initial game state before ready() is called
	for row in range(0,8):
		board_state.append([])
		board_state[row] = [Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty]



# Done
func _on_PieceConversion_id_pressed(id):
	var clr:= swapping_pawn.team
	var new_piece: Piece
	match id:
		0:
			# Queen
			if clr == 'white':
				new_piece = wqueen.instance()
			elif clr == 'blue':
				new_piece = bqueen.instance()
		1:
			# Knight
			if clr == 'white':
				new_piece = wknight.instance()
			elif clr == 'blue':
				new_piece = bknight.instance()
		2:
			# Rook
			if clr == 'white':
				new_piece = wrook.instance()
			elif clr == 'blue':
				new_piece = brook.instance()
		3:
			# Bishop
			if clr == 'white':
				new_piece = wbish.instance()
			elif clr == 'blue':
				new_piece = bbish.instance()
		_:
			$Control/PieceConversion.popup()
	# Set position of new piece
	new_piece.position = Globals.tile_2_xy(swapping_pawn.current_tile)
	# Delete pawn
	swapping_pawn.queue_free()
	# Add new piece to board
	Tiles.add_child(new_piece)
	# Update board state
	board_state[new_piece.current_tile.y][new_piece.current_tile.x] = new_piece.piece_id
	# Unpause tree
	get_tree().paused = false
	# Lock new piece as the turn may have passed before selection
	var wrong_turn = 'blue' if Network.white_team else 'white'
	_lock_pieces(wrong_turn)




# Probably has edge case issues
func _on_CastleKing_pressed():
	# Swap pieces on right.
	var king = wking if Network.white_team else bking
	var rook = wrook_K if Network.white_team else brook_K
	var new_tile = king.current_tile
	new_tile.x += 2
	Network.animate_move(king,new_tile)
	new_tile.x -= 1
	Network.animate_move(rook,new_tile)
	king.has_moved = true
	rook.has_moved = true
	king.has_castled = true
	Network.pass_turn()

# No actually THIS one probably has edge case issues
func _on_CastleQueen_pressed():
	# Swap pieces on left.
	var king = wking if Network.white_team else bking
	var rook = wrook_Q if Network.white_team else brook_Q
	var new_tile = king.current_tile
	new_tile.x -= 2
	Network.animate_move(king,new_tile)
	new_tile.x += 1
	Network.animate_move(rook,new_tile)
	king.has_moved = true
	king.has_castled = true
	rook.has_moved = true
	Network.pass_turn()



#--------------------------------------------------
### Debugging buttons
func _on_Button_pressed():
	Network.white_team = !Network.white_team
	if Network.white_team:
		_unlock_pieces('white')
		_lock_pieces('blue')
	else:
		_unlock_pieces('blue')
		_lock_pieces('white')
	

func _on_MenuButton_pressed():
	print(board_state)
