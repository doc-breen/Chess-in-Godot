extends Piece



func _ready():
	team = 'blue'
	enemy = 'white'
	piece_id = Globals.bR
	
	find_attacks()
	# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	add_to_group(team)
	add_to_group('Pieces')


func find_attacks(state:= board.board_state):
	attacks = []
	var tile_up: Vector2
	var tile_dn: Vector2
	var tile_lt: Vector2
	var tile_rt: Vector2
	for row in range(1,current_tile.y+1):
		tile_up = Vector2(current_tile.x,current_tile.y-row)
		# Check if the space is available
		if board.space_is_empty(tile_up,state):
			attacks.append(tile_up)
		elif board.space_is_enemy(tile_up,state,enemy):
			attacks.append(tile_up)
			break
		else: break
		
	for row in range(current_tile.y+1,8):
		tile_dn = Vector2(current_tile.x,row)
		if board.space_is_empty(tile_dn,state):
			attacks.append(tile_dn)
		elif board.space_is_enemy(tile_dn,state,enemy):
			attacks.append(tile_dn)
			break
		else: break

	for col in range(current_tile.x+1,8):
		tile_rt = Vector2(col,current_tile.y)
		if board.space_is_empty(tile_rt,state):
			attacks.append(tile_rt)
		elif board.space_is_enemy(tile_rt,state,enemy):
			attacks.append(tile_rt)
			break
		else: break
	
	for col in range(1,current_tile.x+1):
		tile_lt = Vector2(current_tile.x-col,current_tile.y)
		if board.space_is_empty(tile_lt,state):
			attacks.append(tile_lt)
		
		elif board.space_is_enemy(tile_lt,state,enemy):
			attacks.append(tile_lt)
			break
		else: break
	

func _on_Piece_is_selected():
	find_attacks(board.board_state)
	# First get the legal moves
	get_legal_tiles(attacks)
	pass_legal_tiles(legal_tiles)


# Unfinished
func _on_Piece_is_dropped():
	# Test if this attacks enemy king
	find_attacks()

#
