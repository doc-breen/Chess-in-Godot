extends Piece


# King specific
var in_check: = false
var never_checked: = true
var has_castled: = false


func _ready():
	team = 'white'
	enemy = 'blue'
	piece_id = Globals.wK
	find_attacks(board.board_state)
	# warning-ignore:return_value_discarded
	connect('piece_selected',self,"_on_Piece_is_selected")
	# warning-ignore:return_value_discarded
	connect('piece_dropped',self,"_on_Piece_is_dropped")
	add_to_group(team)
	add_to_group('Pieces')
	particle_cloud.modulate = Color('1d53c2')


# Done
func find_attacks(_state:=board.board_state):
	var tileN = Vector2(current_tile.x,current_tile.y-1)
	var tileNW = Vector2(current_tile.x-1,current_tile.y-1)
	var tileW = Vector2(current_tile.x-1,current_tile.y)
	var tileSW = Vector2(current_tile.x-1,current_tile.y+1)
	var tileS = Vector2(current_tile.x,current_tile.y+1)
	var tileSE = Vector2(current_tile.x+1,current_tile.y+1)
	var tileE = Vector2(current_tile.x+1,current_tile.y)
	var tileNE = Vector2(current_tile.x+1,current_tile.y-1)
	attacks = [tileN,tileE,tileNE,tileNW,tileS,tileSE,tileSW,tileW]
	var att = []
	# Remove tiles which are OoB
	for a in attacks:
		if a.x >= 0 and a.x < 8 and a.y >= 0 and a.y < 8:
			att.append(a)
	attacks = att


# This function filters out tiles which would put king in check
func get_legal_tiles(tiles: Array):
	legal_tiles = []
	# Set current_tile empty for this
	board.board_state[current_tile.y][current_tile.x] = Globals.empty
	# Prevent moving into check
	var safe_tiles:= []
	var G:= get_tree().get_nodes_in_group(enemy)
	# Loop over attack tiles
	for tyl in tiles:
		# First make sure it's not occupied by teammate
		if !board.space_is_enemy(tyl,board.board_state,team):
			# Also need to be sure it can't be tricked by enemy pieces
			var id_store = board.board_state[tyl.y][tyl.x]
			if id_store > 0:
				board.board_state[tyl.y][tyl.x] = Globals.empty
			# Loop over enemy team
			var g:= 0
			for gy in G:
				# Find tiles which are not under attack
				if board.is_attacking(gy,tyl):
					break
				else:
					g += 1
			if g == len(G):
				# Save the tile
				safe_tiles.append(tyl)
			# Restore board_state before next tyle check
			board.board_state[tyl.y][tyl.x] = id_store
	# Update legal tiles
	legal_tiles = safe_tiles
	# Fix board_state
	board.board_state[current_tile.y][current_tile.x] = Globals.wK


# Done
func _on_Piece_is_selected():
	find_attacks()
	get_legal_tiles(attacks)
	pass_legal_tiles(legal_tiles)


# Done
func get_attacker():
	var attacker = []
	for p in get_tree().get_nodes_in_group(enemy):
		if current_tile in p.attacks:
			attacker.append(p)
	return attacker


# Done
func _on_Piece_is_dropped():
	find_attacks(board.board_state)
	get_legal_tiles(attacks)
