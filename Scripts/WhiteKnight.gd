extends Node2D

var legal_tiles = []
var tile_states = []
onready var main = get_node('/root/Main')
onready var board = get_node('../../Board')
var current_tile: Vector2
var test_tile: Vector2
var attacks = []
onready var piece = $Piece
onready var light = $Light2D
onready var particle_cloud = $CPUParticles2D

func _ready():
	var homie = self.position/Globals.TILE_SIZE
	homie.x = floor(homie.x)
	homie.y = floor(homie.y)
	current_tile = homie
	_find_attacks()

func _get_legal_tiles():
	legal_tiles=[]
	_find_attacks()
	for t in attacks:
		if main.space_is_empty(t) or main.space_is_enemy(t,'blue'):
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
	# End by clearing the array
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

func _find_attacks():
	attacks = []
	# Easiest piece
	var upRt = Vector2(current_tile.x+1,current_tile.y-2)
	var upLt = Vector2(current_tile.x-1,current_tile.y-2)
	var ltUp = Vector2(current_tile.x-2,current_tile.y-1)
	var rtUp = Vector2(current_tile.x+2,current_tile.y-1)
	var dnRt = Vector2(current_tile.x+1,current_tile.y+2)
	var rtDn = Vector2(current_tile.x+2,current_tile.y+1)
	var dnLt = Vector2(current_tile.x-1,current_tile.y+2)
	var ltDn = Vector2(current_tile.x-2,current_tile.y+1)
	attacks = [upRt,upLt,ltUp,rtUp,dnRt,dnLt,rtDn,ltDn]


func _on_Piece_is_selected():
	light.visible = true
	particle_cloud.visible = true
	z_index = 40
	_show_tiles()

func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.wN)
		current_tile = test_tile
	
	light.visible = false
	particle_cloud.visible = false
	z_index = 0
	_unshow_tiles()
	_find_attacks()

