extends Node2D

const TILE_SIZE = 64
var legal_tiles = []
var current_tile: Vector2
var tile_states = []
onready var board = get_node('../../Board')
onready var main = get_node('../../../Main')
var test_tile: Vector2
var attacks = []
onready var piece = $Piece

func _ready():
	var homie = self.position/TILE_SIZE
	homie.x = floor(homie.x)
	homie.y = floor(homie.y)
	current_tile = homie
	_find_attacks()

func _get_legal_tiles():
	
	legal_tiles=[]
	_find_attacks()
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
	# End by clearing the legal_tiles
	
	tile_states=[]

func _move_check() -> bool:
	var test_pos = get_global_mouse_position()/TILE_SIZE
	test_tile.x = floor(test_pos.x)
	test_tile.y = floor(test_pos.y)
	# See if it's green
	if board.get_cellv(test_tile) == 6:
		return true
	else:
		return false

func _find_attacks():
	# need to check and display x and y tiles if
	var diagNW
	var diagNE
	var diagSW
	var diagSE
	attacks = []
	for d in range(1,current_tile.x+1):
		diagNW = Vector2(current_tile.x-d,current_tile.y-d)
		if main.space_is_empty(diagNW):
			attacks.append(diagNW)
		else:
			attacks.append(diagNW)
			break
		
	for d in range(1,current_tile.x+1):
		diagSW = Vector2(current_tile.x-d,current_tile.y+d)
		if main.space_is_empty(diagSW):
			attacks.append(diagSW)
		else:
			attacks.append(diagSW)
			break
	
	var c = 1
	for d in range(current_tile.x+1,8):
		diagNE = Vector2(d,current_tile.y-c)
		if main.space_is_empty(diagNE):
			attacks.append(diagNE)
		else:
			attacks.append(diagNE)
			break
		c+=1
	
	c = 1
	for d in range(current_tile.x+1,8):
		diagSE = Vector2(d,current_tile.y+c)
		if main.space_is_empty(diagSE):
			attacks.append(diagSE)
		else:
			attacks.append(diagSE)
			break
		c+=1

func _on_Piece_is_selected():
	$Light2D.visible = true
	$CPUParticles2D.visible = true
	z_index = 40
	_show_tiles()


func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.bB)
		current_tile = test_tile
	$CPUParticles2D.visible = false
	$Light2D.visible = false
	z_index = 0
	_unshow_tiles()
	_find_attacks()
