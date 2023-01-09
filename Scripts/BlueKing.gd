extends Node2D


var legal_tiles = []
var current_tile: Vector2
var tile_states = []
var has_moved = false
onready var board = get_node('../../Board')
onready var main = get_node('/root/Main')
var test_tile: Vector2
var attacks = []
var check = false
onready var piece = $Piece
onready var light = $Light2D
onready var particle_cloud = $CPUParticles2D
var can_castle = false
signal cRight()
signal cLeft()
var never_checked = true

func _ready():
	# Initialize home tile
	current_tile = Globals.xy_2_tile(self.position)
	# Store attackable tiles
	find_attacks()
	# warning-ignore:return_value_discarded
	connect("cLeft",main,"_on_cLeft_received")
	# warning-ignore:return_value_discarded
	connect("cRight",main,"_on_cRight_received")
	# warning-ignore:return_value_discarded
	Network.connect("blue_team_test",self,"_on_team_test")

func _process(_delta):
	if main.checkCheck(current_tile,'white'):
		check = true
		never_checked = false

func castling_test():
	# Test for castling
	if !has_moved and never_checked:
		if main.space_is_empty(Vector2(5,0)) and main.space_is_empty(Vector2(6,0)):
			can_castle = true
			emit_signal("cRight")
		if main.space_is_empty(Vector2(3,0)) and main.space_is_empty(Vector2(2,0)) and main.space_is_empty(Vector2(1,0)):
			can_castle = true
			emit_signal("cLeft")

func _get_legal_tiles():
	# need to check and display x and y tiles if available.
	legal_tiles = []
	find_attacks()
	for t in attacks:
		if main.space_is_empty(t) and !main.checkCheck(t,'white'):
			legal_tiles.append(t)
		elif main.space_is_enemy(t,'white') and !main.checkCheck(t,'white'):
			legal_tiles.append(t)
	
func _on_team_test():
	if main.checkCheck(current_tile,"white"):
		print("Blue King in Check!")
	

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

func find_attacks():
	# Store all moves in array
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
	light.visible = true
	z_index = 40
	particle_cloud.visible = true
	_show_tiles()


func _on_Piece_is_dropped():
	if _move_check():
		
		piece.move_piece(test_tile,Globals.bK)
		current_tile = test_tile
		if has_moved == false:
			has_moved = true
	
	particle_cloud.visible = false
	light.visible = false
	z_index = 0
	_unshow_tiles()
	find_attacks()
