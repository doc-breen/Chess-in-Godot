extends Node2D

const TILE_SIZE = 64
var legal_tiles = []
var current_tile: Vector2
var tile_states = []
var has_moved = false
onready var board = get_node('../../Board')
onready var main = get_node('../../../Main')
var test_tile: Vector2
var attacks = []
var check = false
onready var piece = $Piece


func _ready():
	var homie = self.position/TILE_SIZE
	homie.x = floor(homie.x)
	homie.y = floor(homie.y)
	current_tile = homie
	_find_attacks()

func _get_legal_tiles():
	# need to check and display x and y tiles if
	# available.  Also rules for castling...
	legal_tiles=[]
	_find_attacks()
	for t in attacks:
		if main.space_is_empty(t) and !main.checkCheck(t,'white'):
			legal_tiles.append(t)
		elif main.space_is_enemy(t,'white') and !main.checkCheck(t,'white'):
			legal_tiles.append(t)
	

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
	
	var tileN = Vector2(current_tile.x,current_tile.y-1)
	var tileS = Vector2(current_tile.x,current_tile.y+1)
	var tileW = Vector2(current_tile.x-1,current_tile.y)
	var tileE = Vector2(current_tile.x+1,current_tile.y)
	var tileNE = Vector2(current_tile.x+1,current_tile.y-1)
	var tileNW = Vector2(current_tile.x-1,current_tile.y-1)
	var tileSW = Vector2(current_tile.x-1,current_tile.y+1)
	var tileSE = Vector2(current_tile.x+1,current_tile.y+1)
	attacks = [tileN,tileS,tileW,tileE,tileNE,tileNW,tileSW,tileSE]
	

func _on_Piece_is_selected():
	$Light2D.visible = true
	z_index = 40
	$CPUParticles2D.visible = true
	_show_tiles()


func _on_Piece_is_dropped():
	if _move_check():
		
		piece.move_piece(test_tile,Globals.bK)
		current_tile = test_tile
		if has_moved == false:
			has_moved = true
	$CPUParticles2D.visible = false
	$Light2D.visible = false
	z_index = 0
	_unshow_tiles()
	_find_attacks()
