extends Node2D

var legal_tiles = []
var current_tile: Vector2
var tile_states = []
var attacks = []
var has_moved = false
onready var board = get_node('../../Board')
onready var main = get_node('/root/Main')
var test_tile: Vector2
onready var piece = $Piece
onready var light = $Light2D
onready var particle_cloud = $CPUParticles2D

func _ready():
	var homie = self.position/Globals.TILE_SIZE
	homie.x = floor(homie.x)
	homie.y = floor(homie.y)
	current_tile = homie
	find_attacks()

func _get_legal_tiles():
	
	legal_tiles=[]
	find_attacks()
	
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
	var test_pos = get_global_mouse_position()/Globals.TILE_SIZE
	test_tile.x = floor(test_pos.x)
	test_tile.y = floor(test_pos.y)
	# See if it's green
	if board.get_cellv(test_tile) == 6:
		return true
	else:
		return false

func find_attacks():
	attacks = []
	var tile_up
	var tile_dn
	var tile_lt
	var tile_rt
	for row in range(1,current_tile.y+1):
		tile_up = Vector2(current_tile.x,current_tile.y-row)
		# Check if the space is available
		if main.space_is_empty(tile_up):
			attacks.append(tile_up)
		else:
			attacks.append(tile_up)
			break
		
	for row in range(current_tile.y+1,8):
		tile_dn = Vector2(current_tile.x,row)
		if main.space_is_empty(tile_dn):
			attacks.append(tile_dn)
		else:
			attacks.append(tile_dn)
			break

	for col in range(current_tile.x+1,8):
		tile_rt = Vector2(col,current_tile.y)
		if main.space_is_empty(tile_rt):
			attacks.append(tile_rt)
		else:
			attacks.append(tile_rt)
			break
	
	for col in range(1,current_tile.x+1):
		tile_lt = Vector2(current_tile.x-col,current_tile.y)
		if main.space_is_empty(tile_lt):
			attacks.append(tile_lt)
		
		else:
			attacks.append(tile_lt)
			break
	

func _on_Piece_is_selected():
	light.visible = true
	z_index = 40
	particle_cloud.visible = true
	_show_tiles()


func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.bR)
		current_tile = test_tile
		if has_moved == false:
			has_moved = true
	particle_cloud.visible = false
	light.visible = false
	z_index = 0
	_unshow_tiles()
	find_attacks()

