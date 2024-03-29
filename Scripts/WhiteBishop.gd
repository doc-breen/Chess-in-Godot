extends Piece


func _ready():
	team = 'white'
	enemy = 'blue'
	piece_id = Globals.wB
	find_attacks()
# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	# warning-ignore:return_value_discarded
	connect("piece_dropped",self,'_on_Piece_is_dropped')
	add_to_group(team)
	add_to_group('Pieces')
	particle_cloud.modulate = Color('1d53c2')

# Done
func find_attacks(state: Array=board.board_state):
	if state[current_tile.y][current_tile.x] == piece_id:
		var diagNW: Vector2
		var diagNE: Vector2
		var diagSE: Vector2
		var diagSW: Vector2
		attacks = []
		# Loop over tiles, checking if square is occupied
		for d in range(1,current_tile.x+1):
			diagNW = Vector2(current_tile.x-d,current_tile.y-d)
			if diagNW.x < 0 or diagNW.y < 0 or diagNW.x > 7 or diagNW.y > 7:
				continue
			elif board.space_is_empty(diagNW,state):
				attacks.append(diagNW)
			elif board.space_is_enemy(diagNW,state,enemy):
				attacks.append(diagNW)
				break
			else: break
		for d in range(1,current_tile.x+1):
			diagSW = Vector2(current_tile.x-d,current_tile.y+d)
			if diagSW.x < 0 or diagSW.y < 0 or diagSW.x > 7 or diagSW.y > 7:
				continue
			elif board.space_is_empty(diagSW,state):
				attacks.append(diagSW)
			elif board.space_is_enemy(diagSW,state,enemy):
				attacks.append(diagSW)
				break
			else: break
		
		var c = 1
		for d in range(current_tile.x+1,8):
			diagNE = Vector2(d,current_tile.y-c)
			if diagNE.x < 0 or diagNE.y < 0 or diagNE.x > 7 or diagNE.y > 7:
				continue
			elif board.space_is_empty(diagNE,state):
				attacks.append(diagNE)
			elif board.space_is_enemy(diagNE,state,enemy):
				attacks.append(diagNE)
				break
			else: break
			c+=1
		c = 1
		for d in range(current_tile.x+1,8):
			diagSE = Vector2(d,current_tile.y+c)
			if diagSE.x < 0 or diagSE.y < 0 or diagSE.x > 7 or diagSE.y > 7:
				continue
			elif board.space_is_empty(diagSE,state):
				attacks.append(diagSE)
			elif board.space_is_enemy(diagSE,state,enemy):
				attacks.append(diagSE)
				break
			else: break
			c += 1
	else: attacks = []


# Done
func _on_Piece_is_selected():
	find_attacks(board.board_state)
	# Bishop legal moves only need to be filtered
	get_legal_tiles(attacks)
	pass_legal_tiles(legal_tiles)


# Done
func _on_Piece_is_dropped():
	find_attacks(board.board_state)

		
