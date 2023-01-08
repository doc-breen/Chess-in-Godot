extends Node

enum {empty,wP,wB,wR,wN,wQ,wK,bP,bB,bR,bN,bQ,bK}
const TILE_SIZE = 64

# Some network reason?
var otherPlayerId = -1


# A couple of functions for coordinate transforms
func tile_2_xy(tile) -> Vector2:
	# Convert tilemap coords to global coords
	var pos: Vector2
	pos = TILE_SIZE*Vector2((2*tile.x + 1)/2,(2*tile.y +1)/2)
	return pos

func xy_2_tile(position) -> Vector2:
	# Convert global coords to tilemap coords
	# warning-ignore:unassigned_variable
	# It is pretty dumb that I have to suppress this warning.
	# Shouldn't the engine be able to tell that the x and y values are assigned?
	var tile: Vector2
	tile.x = floor(position.x/TILE_SIZE)
	tile.y = floor(position.y/TILE_SIZE)
	return tile
