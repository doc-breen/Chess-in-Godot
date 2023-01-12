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
	self.add_to_group("white")
	current_tile = Globals.xy_2_tile(self.position)
	find_attacks(main.board_state)

func _get_legal_tiles():
	find_attacks(main.board_state)
	legal_tiles=[]
	for tile in attacks:
		if main.space_is_empty(tile) or main.space_is_enemy(tile,'blue'):
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
	# End by clearing the legal_tiles
	
	tile_states=[]

func _move_check() -> bool:
	var test_pos = get_global_mouse_position()/Globals.TILE_SIZE
	test_tile.x = floor(test_pos.x)
	test_tile.y = floor(test_pos.y)
	# See if it's green
	if board.get_cellv(test_tile) == 6:
		return true
	else:
		return false

func find_attacks(test_state):
	attacks = []
	# need to check and display x and y tiles if
	var tileN
	var tileS
	var tileW
	var tileE
	var tileNE
	var tileNW
	var tileSW
	var tileSE
	for col in range(1,current_tile.y+1):
		tileN = Vector2(current_tile.x,current_tile.y-col)
		if main.space_is_empty(tileN,test_state):
			attacks.append(tileN)
		else:
			attacks.append(tileN)
			break
	for col in range(current_tile.y+1,8):
		tileS = Vector2(current_tile.x,col)
		attacks.append(tileS)
		if !main.space_is_empty(tileS,test_state):
			break
	
	for row in range(current_tile.x+1,8):
		tileE = Vector2(row,current_tile.y)
		attacks.append(tileE)
		if !main.space_is_empty(tileE,test_state):
			break
	for row in range(1,current_tile.x+1):
		tileW = Vector2(current_tile.x-row,current_tile.y)
		attacks.append(tileW)
		if !main.space_is_empty(tileW,test_state):
			break
		
	# Bishop moves
	for d in range(1,current_tile.x+1):
		tileNW = Vector2(current_tile.x-d,current_tile.y-d)
		attacks.append(tileNW)
		if !main.space_is_empty(tileNW,test_state):
			break
		
	for d in range(1,current_tile.x+1):
		tileSW = Vector2(current_tile.x-d,current_tile.y+d)
		attacks.append(tileSW)
		if !main.space_is_empty(tileNW,test_state):
			break
	var c = 1
	for d in range(current_tile.x+1,8):
		tileNE = Vector2(d,current_tile.y-c)
		attacks.append(tileNE)
		if !main.space_is_empty(tileNE,test_state):
			break
		c+=1
	c = 1
	for d in range(current_tile.x+1,8):
		tileSE = Vector2(d,current_tile.y+c)
		attacks.append(tileSE)
		if !main.space_is_empty(tileSE,test_state):
			break
		c+=1


func _on_Piece_is_selected():
	light.visible = true
	particle_cloud.visible = true
	z_index = 40
	_show_tiles()

func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.wQ)
		current_tile = test_tile
	
	particle_cloud.visible = false
	light.visible = false
	z_index = 0
	_unshow_tiles()
	find_attacks(main.board_state)
	
