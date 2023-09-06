extends Node

# enum for calling pieces
enum {empty,wP,wB,wR,wN,wQ,wK,bP,bB,bR,bN,bQ,bK}
# tile size for Chess board
const TILE_SIZE:= 64


# For converting screen coordinates to tile coordinates
func xy_2_tile(pos:Vector2) -> Vector2:
	# warning-ignore:unassigned_variable
	var tile: Vector2
	tile.x = floor(pos.x/TILE_SIZE)
	tile.y = floor(pos.y/TILE_SIZE)
	return tile

# Tile to screen coords
func tile_2_xy(tile:Vector2) -> Vector2:
	var pos
	pos = TILE_SIZE*Vector2((2*tile.x + 1)/2,(2*tile.y +1)/2)
	return pos


# OoB checker
func OoB_test(tile: Vector2) -> bool:
	if tile.x < 0 or tile.y < 0 or tile.x > 7 or tile.y > 7:
		return true
	else:
		return false
