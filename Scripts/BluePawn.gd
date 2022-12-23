extends Node2D
# This script needs to contain movement restrictions

var legal_tiles = []
var current_tile: Vector2
# Stores the previous tile information for highlighting
# This will be important after chess is finished
var tile_states = []
var attacks = []
onready var piece = $Piece
onready var light = $Light2D
onready var particle_cloud = $CPUParticles2D

var test_tile: Vector2 # For checking move validity

signal convert_piece(tile)

# Set easy access to TileMap properties and game states
onready var board = get_node('../../Board')
onready var main = get_node('/root/Main')

func _ready():
	var homie = self.position/Globals.TILE_SIZE
	homie.x = floor(homie.x)
	homie.y = floor(homie.y)
	current_tile = homie
	attacks.append(Vector2.ZERO)
	attacks.append(Vector2.ZERO)
	_find_attacks(current_tile)

func _get_legal_tiles():
	legal_tiles=[]
	_find_attacks(current_tile)
	for t in attacks:
		if main.space_is_enemy(t,'white'):
			legal_tiles.append(t)
	
	var up_one = Vector2(current_tile.x,current_tile.y+1)
	if main.space_is_empty(up_one):
		legal_tiles.append(up_one)
		if current_tile.y == 1:
			var up_two = Vector2(current_tile.x,current_tile.y+2)
			if main.space_is_empty(up_two):
				legal_tiles.append(up_two)
			

func _show_tiles():
	_get_legal_tiles()
	for t in legal_tiles:
		tile_states.append(board.get_cellv(t))
		board.set_cellv(t,6)

func _unshow_tiles():
	if len(tile_states) > 0:
		for t in range(0,len(tile_states)):
			# Consider changing this to a signal emit to Board.gd
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

func _find_attacks(tile):
	
	attacks[0] = Vector2(tile.x-1,tile.y+1)
	attacks[1] = Vector2(tile.x+1,tile.y+1)


func _on_Piece_is_selected():
	particle_cloud.visible = true
	light.visible = true
	
	z_index = 40
	_show_tiles()

func _on_Piece_is_dropped():
	if _move_check():
		piece.move_piece(test_tile,Globals.bP)
		current_tile = test_tile
	particle_cloud.visible = false
	light.visible = false
	
	z_index = 0
	_unshow_tiles()
	_find_attacks(current_tile)
	# Only for pawn, check if in enemy home row to convert piece
	if current_tile.y == 7:
		emit_signal("convert_piece",current_tile)

