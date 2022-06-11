extends Node2D
# This scene contains the board with instanced pieces.  It is the
# initial game state
# This script needs to handle check situations.  Should be at the
# end of each player's turn

const TILE_SIZE = 64

# board_state is a 2D array needed so pieces can easily check if
# a square is occupied. 
var board_state = [[]]

onready var board = $Board

func _ready():
	pass
	

func space_is_empty(tile) -> bool:
	# This function will be called by pieces when checking
	# for legal spaces to highlight. tile is a Vector2
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	if (board_state[tile.y][tile.x] == Globals.empty):
		return true
	else: 
		return false

# team_color should be the color of the enemy team
func space_is_enemy(tile,team_color) -> bool:
	# Check edge
	if tile.x > 7 or tile.y > 7 or tile.x < 0 or tile.y < 0:
		return false
	
	var team = []
	if team_color == 'white':
		team = [1,2,3,4,5,6]
	if team_color == 'blue':
		team = [7,8,9,10,11,12]
	
	if board_state[tile.y][tile.x] in team:
		return true
	else:
		return false

# Check checker for checking if in check
func checkCheck(tile,team_color):
	var team: String
	if team_color == 'white':
		team = 'WhiteTeam'
	elif team_color == 'blue':
		team = 'BlueTeam'
	var team_nodes = get_tree().get_nodes_in_group(team)
	var count = 0
	for n in team_nodes:
		count += 1
		# Each piece scene has a variable attacks which
		# stores the tiles that piece can "see"
		if tile in n.attacks:
			# Check
			return true
		# Return false at the end of the for loop
		if count == len(team_nodes):
			return false

# Capture goes here because it reduces the number of signals
func _on_Piece_capture(area):
	area.get_parent().queue_free()

# Update the board_state
func _on_Piece_update_board(old_tile, new_tile, id):
	# clear old space
	board_state[old_tile.y][old_tile.x] = Globals.empty
	# Place new piece
	board_state[new_tile.y][new_tile.x] = id


func _on_Board_tree_entered():
	# Initialize board
	# Has to be done before ready because other nodes
	# call board_state
	board_state[0] = [Globals.bR,Globals.bN,Globals.bB,Globals.bQ,
					Globals.bK,Globals.bB,Globals.bN,Globals.bR]
	board_state.append([])
	board_state[1] =[Globals.bP,Globals.bP,Globals.bP,Globals.bP,
					Globals.bP,Globals.bP,Globals.bP,Globals.bP] 
	for row in range(2,6):
		board_state.append([])
		board_state[row] = [Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty,Globals.empty,
					Globals.empty,Globals.empty]
	board_state.append([])
	board_state[6] = [Globals.wP,Globals.wP,Globals.wP,Globals.wP,
					Globals.wP,Globals.wP,Globals.wP,Globals.wP]
	board_state.append([])
	board_state[7] = [Globals.wR,Globals.wN,Globals.wB,Globals.wQ,
					Globals.wK,Globals.wB,Globals.wN,Globals.wR]


func _on_HostButton_pressed():
	pass # Replace with function body.


func _on_JoinButton_pressed():
	pass # Replace with function body.
