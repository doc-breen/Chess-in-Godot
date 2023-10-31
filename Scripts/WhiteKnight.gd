extends Piece

func _ready():
	team = 'white'
	enemy = 'blue'
	piece_id = Globals.wN
	
	find_attacks(board.board_state)
	# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	# warning-ignore:return_value_discarded
	connect("piece_dropped",self,'_on_Piece_is_dropped')
	add_to_group(team)
	add_to_group('Pieces')
	particle_cloud.modulate = Color('1d53c2')


# Done
func find_attacks(state:=board.board_state):
	if state[current_tile.y][current_tile.x] == piece_id:
		# Knight is the easiest of all
		var upRt = Vector2(current_tile.x+1,current_tile.y-2)
		var upLt = Vector2(current_tile.x-1,current_tile.y-2)
		var ltUp = Vector2(current_tile.x-2,current_tile.y-1)
		var rtUp = Vector2(current_tile.x+2,current_tile.y-1)
		var dnRt = Vector2(current_tile.x+1,current_tile.y+2)
		var rtDn = Vector2(current_tile.x+2,current_tile.y+1)
		var dnLt = Vector2(current_tile.x-1,current_tile.y+2)
		var ltDn = Vector2(current_tile.x-2,current_tile.y+1)
		attacks = [upRt,upLt,ltUp,rtUp,dnRt,dnLt,rtDn,ltDn]
		var good_tiles = []
		for att in attacks:
			if att.y >= 0 and att.x >= 0 and att.y < 8 and att.x < 8:
				good_tiles.append(att)
		attacks = good_tiles
	else: attacks = []


# Works for now
func get_legal_tiles(tiles):
	# Just check that attack isn't occupied by teammate
	legal_tiles = tiles.duplicate(true)
	var good_tiles = []
	for t in tiles:
		if not board.space_is_enemy(t,board.board_state,team):
			good_tiles.append(t)
			
	legal_tiles = good_tiles


func _on_Piece_is_selected():
	find_attacks()
	get_legal_tiles(attacks)
	# First get the legal moves
	pass_legal_tiles(legal_tiles)


# Works, but is unfinished?
func _on_Piece_is_dropped():
	# Test if this attacks enemy king
	find_attacks(board.board_state)
