extends Node2D


var legal_tiles = []
var current_tile: Vector2
var tile_states = []
onready var board = get_node('../../Board')
onready var main = get_node('/root/Main')
var test_tile: Vector2
var attacks = []
onready var piece = $Piece
onready var light = $Light2D
onready var particle_cloud = $CPUParticles2D

func _ready():
	current_tile = Globals.xy_2_tile(self.position)
	find_attacks(main.board_state)

func _get_legal_tiles():
	legal_tiles=[]
	
	# First check if movement will put king in check
	if main.checkCheck(current_tile,'white'):
		# Duplicate board state
		var test_state = main.board_state
		# Remove this piece from test_state
		test_state[current_tile.y][current_tile.x] = Globals.empty
	
	find_attacks(main.board_state)
	for tile in attacks:
		if main.space_is_empty(tile) or main.space_is_enemy(tile,'white'):
			legal_tiles.append(tile)
	

func _show_tiles():
	_get_legal_tiles()
	for t in legal_tiles:
		tile_states.append(board.get_cellv(t))
		board.set_cellv(t,6)

func _unshow_tiles():
	if len(tile_states) > 0:
		for t in range(0,len(tile_states)):
			board.set_cellv(legal_tiles[t],tile_states[t])
	# End by clearing the tiles
	
	tile_states=[]

func _move_check() -> bool:
	# return false if blue king is in check or will be in check after moving
	# If checkCheck is called during this function, will return incorrectly
	test_tile = Globals.xy_2_tile(get_global_mouse_position())
	# See if it's green
	if board.get_cellv(test_tile) == 6:
		return true
	else:
		return false

func find_attacks(test_state):
	# need to check and display x and y tiles if
	var diagNW
	var diagNE
	var diagSW
	var diagSE
	attacks = []
	for d in range(1,current_tile.x+1):
		diagNW = Vector2(current_tile.x-d,current_tile.y-d)
		if main.space_is_empty(diagNW,test_state):
			attacks.append(diagNW)
		else:
			attacks.append(diagNW)
			break
		
	for d in range(1,current_tile.x+1):
		diagSW = Vector2(current_tile.x-d,current_tile.y+d)
		if main.space_is_empty(diagSW,test_state):
			attacks.append(diagSW)
		else:
			attacks.append(diagSW)
			break
	
	var c = 1
	for d in range(current_tile.x+1,8):
		diagNE = Vector2(d,current_tile.y-c)
		if main.space_is_empty(diagNE,test_state):
			attacks.append(diagNE)
		else:
			attacks.append(diagNE)
			break
		c+=1
	
	c = 1
	for d in range(current_tile.x+1,8):
		diagSE = Vector2(d,current_tile.y+c)
		if main.space_is_empty(diagSE,test_state):
			attacks.append(diagSE)
		else:
			attacks.append(diagSE)
			break
		c += 1

func _on_Piece_is_selected():
	# First test to make sure moving this piece won't place king in check
	main.test_check(current_tile,'white')
	
	light.visible = true
	particle_cloud.visible = true
	z_index = 40
	_show_tiles()


func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.bB)
		current_tile = test_tile
	particle_cloud.visible = false
	light.visible = false
	z_index = 0
	_unshow_tiles()
	find_attacks(main.board_state)
