extends Node

var white_team:= true
signal team_change(team)
signal update_board(old_tile,new_tile,piece_id)


func _ready():
	pass

remote func animate_move(piece_obj:Piece, tile:Vector2):
	# Move piece from tile1 to tile2
	# This function is used for castling in local hotseat play
	# It will also be used for animating all moves for opponent over wifi
	var pos1 = piece_obj.current_tile
	var pos2 = Globals.tile_2_xy(tile)
	emit_signal("update_board",piece_obj.current_tile,tile,piece_obj.piece_id)
	piece_obj.pick_area.home_position = lerp(pos1,pos2,1)
	piece_obj.current_tile = tile
	

# Possibly finished
func pass_turn():
	white_team = !white_team
	# Change which player can move pieces
	emit_signal("team_change",white_team)


# Unfinished
func on_game_over():
	# Display UI element that indicates which team won
	# The UI element itself can pause the scene tree
	print('Checkmate')

