extends Piece



func _ready():
	self.team = 'white'
	self.enemy = 'blue'
	self.piece_id = Globals.wQ
	find_attacks(board.board_state)
	# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	# warning-ignore:return_value_discarded
	connect("piece_dropped",self,'_on_Piece_is_dropped')
	add_to_group(team)
	add_to_group('Pieces')


func find_attacks(state:= board.board_state):
	if state[current_tile.y][current_tile.x] == piece_id:
		attacks = []
		var tileN: Vector2
		var tileS: Vector2
		var tileW: Vector2
		var tileE: Vector2
		var tileNE: Vector2
		var tileNW: Vector2
		var tileSW: Vector2
		var tileSE: Vector2
		# Rook moves
		for col in range(1,current_tile.y+1):
			tileN = Vector2(current_tile.x,current_tile.y-col)
			if Globals.OoB_test(tileN):
				continue
			elif board.space_is_empty(tileN,state):
				attacks.append(tileN)
			elif board.space_is_enemy(tileN,state,enemy):
				attacks.append(tileN)
				break
			else: break
		
		for col in range(current_tile.y+1,8):
			tileS = Vector2(current_tile.x,col)
			if Globals.OoB_test(tileS):
				continue
			elif board.space_is_empty(tileS,state):
				attacks.append(tileS)
			elif board.space_is_enemy(tileS,state,enemy):
				attacks.append(tileS)
				break
			else: break
				
		for row in range(current_tile.x+1,8):
			tileE = Vector2(row,current_tile.y)
			if board.space_is_empty(tileE,state):
				attacks.append(tileE)
			
			elif board.space_is_enemy(tileE,state,enemy):
				attacks.append(tileE)
				break
			else: break
			
		for row in range(1,current_tile.x+1):
			tileW = Vector2(current_tile.x-row,current_tile.y)
			if board.space_is_empty(tileW,state):
				attacks.append(tileW)
			
			elif board.space_is_enemy(tileW,state,enemy):
				attacks.append(tileW)
				break
			else: break
			
		# Bishop moves
		for d in range(1,current_tile.x+1):
			tileNW = Vector2(current_tile.x-d,current_tile.y-d)
			if board.space_is_empty(tileNW,state):
				attacks.append(tileNW)
			
			elif board.space_is_enemy(tileNW,state,enemy):
				attacks.append(tileNW)
				break
			else: break
			
		for d in range(1,current_tile.x+1):
			tileSW = Vector2(current_tile.x-d,current_tile.y+d)
			if board.space_is_empty(tileSW,state):
				attacks.append(tileSW)
			
			elif board.space_is_enemy(tileSW,state,enemy):
				attacks.append(tileSW)
				break
			else: break
		var c = 1
		for d in range(current_tile.x+1,8):
			tileNE = Vector2(d,current_tile.y-c)
			if board.space_is_empty(tileNE,state):
				attacks.append(tileNE)
			
			elif board.space_is_enemy(tileNE,state,enemy):
				attacks.append(tileNE)
				break
			else: break
			c+=1
		
		c = 1
		for d in range(current_tile.x+1,8):
			tileSE = Vector2(d,current_tile.y+c)
			if board.space_is_empty(tileSE,state):
				attacks.append(tileSE)
			elif board.space_is_enemy(tileSE,state,enemy):
				attacks.append(tileSE)
				break
			else: break
			c+=1
	else: attacks = []

func _on_Piece_is_selected():
	find_attacks(board.board_state)
	get_legal_tiles(attacks)
	pass_legal_tiles(legal_tiles)


func _on_Piece_is_dropped():
	# Test if this attacks enemy king
	find_attacks(board.board_state)
