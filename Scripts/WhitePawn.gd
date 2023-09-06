extends Piece

signal convert_pawn(pawn)

func _ready():
	# Use self because super class variables
	team = 'white'
	enemy = 'blue'
	piece_id = Globals.wP
	
	find_attacks()
	# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	# warning-ignore:return_value_discarded
	connect("piece_dropped",self,'_on_Piece_is_dropped')
	add_to_group(team)
	add_to_group('Pieces')
	# warning-ignore:return_value_discarded
	connect("convert_pawn",board,"_on_Pawn_converted")


# Done
func find_attacks(state:= board.board_state):
	if state[current_tile.y][current_tile.x] == piece_id:
		attacks = [Vector2(current_tile.x-1,current_tile.y-1),
				Vector2(current_tile.x+1,current_tile.y-1)]
	else: attacks = []


# Done?
func get_legal_tiles(tiles):
	var normal_move = Vector2(current_tile.x,current_tile.y-1)
	legal_tiles = []
	if board.space_is_empty(normal_move,board.board_state):
		legal_tiles.append(normal_move)
		if !has_moved:
			var extra_move = Vector2(current_tile.x,current_tile.y-2)
			if board.space_is_empty(extra_move,board.board_state):
				legal_tiles.append(extra_move)
	
	for t in tiles:
		if board.space_is_enemy(t,board.board_state,enemy):
			legal_tiles.append(t)


# Untested
func _on_Piece_is_selected():
	# Pawn is only piece which moves differently from attacking
	find_attacks()
	# First get the legal moves
	get_legal_tiles(attacks)
	# Then pass legal moves
	pass_legal_tiles(legal_tiles)


# Done?
func _on_Piece_is_dropped():
	find_attacks(board.board_state)
	# Pawn conversion
	if current_tile.y == 0:
		emit_signal('convert_pawn',self)
