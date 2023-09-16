class_name Piece
extends Node2D

# The Piece class contains general behavior that all chess pieces share or need
# access to.  The parent is always the Board scene, and the InputArea controls
# how the player interacts with pieces.

var current_tile: Vector2
export var team: String
export var enemy: String
export var piece_id: int
var attacks: = []
var legal_tiles: = []
# Boolean to track if piece has ever moved for pawns, kings, and rooks.
var has_moved = false
# This is necessary to avoid edge case bugs with turn passing
var turn_complete = false
# References to other required nodes
onready var pick_area = $InputArea
onready var board = get_node("/root/Board")
onready var light = $Light2D
signal unshow_tiles(attack_list)
signal update_board(old_tile, new_tile, node)
signal filter_attacks(list, node)
#signal check_event(node, team)
signal piece_selected
signal piece_dropped
onready var move_sound = $MoveSound
onready var drop_sound = $DropSound
onready var cap_sound = $CapSound
onready var pick_sound = $PickSound


func _ready():
	current_tile = Globals.xy_2_tile(position)
	# warning-ignore:return_value_discarded
	connect("unshow_tiles",board,"_on_tiles_off_signal")
	# warning-ignore:return_value_discarded
	connect("update_board",board,"_on_board_updated")
	# warning-ignore:return_value_discarded
	connect("filter_attacks",board,"_on_attacks_received")
	



func find_attacks(_state:Array = board.board_state):
	pass


# Default behavior for easy pieces like Rook
func get_legal_tiles(tiles:Array):
	legal_tiles = tiles


func pass_legal_tiles(attack_list:Array):
	# Send the list to board for filtering
	emit_signal("filter_attacks",attack_list,self)


func vfx_on():
	# Lights
	light.enabled = true
	# Height
	z_index = 50


func vfx_off():
	light.enabled = false
	z_index = 0


func _on_InputArea_is_selected():
	# Any graphical effects of picking up piece go here
	vfx_on()
	pick_sound.playing = true
	emit_signal("piece_selected")


func _on_InputArea_released():
	# Make sure location is a lit tile
	var test_tile = Globals.xy_2_tile(get_global_mouse_position())
	if board.move_test(test_tile):
		
		# Update current_tile
		var prev_tile: = current_tile
		current_tile = test_tile
		# Update screen position
		pick_area.home_position = Globals.tile_2_xy(current_tile)
		# Update game state
		if has_moved == false:
			has_moved = true
		# Capture
		var cap_area = pick_area.get_overlapping_areas()
		if cap_area:
			_on_Piece_captured(cap_area[0])
			cap_sound.playing = true
		else:
			move_sound.playing = true
		emit_signal("update_board",prev_tile,current_tile,piece_id)
		turn_complete = true
		# Test if this attacks enemy king?
	else:
		drop_sound.playing = true
	
	
	emit_signal("unshow_tiles",legal_tiles)
	emit_signal("piece_dropped")
	# Turn off graphical effects
	vfx_off()
	
	# End turn
	if turn_complete:
		turn_complete = false
		Network.pass_turn()
		



func _on_Piece_captured(area):
	area.get_parent().queue_free()

