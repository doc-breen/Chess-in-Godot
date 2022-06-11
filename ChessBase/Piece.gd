extends Area2D
class_name Piece

const TILE_SIZE = 64
var selected = false
var homie: Vector2
signal is_selected
signal is_dropped
signal capture(area)
signal update_board(current_tile,new_tile,id)
onready var main = get_node('/root/Main')

func _ready():
	homie = get_parent().position
# warning-ignore:return_value_discarded
	connect("update_board",main,"_on_Piece_update_board")
# warning-ignore:return_value_discarded
	connect("capture",main,"_on_Piece_capture")

func _process(delta):
	# When selected, piece follows mouse movement
	if selected:
		_followMouse(delta)
	# When dropped, piece checks board for legal move
	# If move is not legal, piece returns to original tile
	else: 
		get_parent().position = lerp(get_parent().position, homie,22*delta)
	
# Track mouse movement
func _followMouse(delta):
	var mouse_pos = get_global_mouse_position()
	get_parent().position = lerp(get_parent().position,mouse_pos,77*delta)

# This is the function to pick up the piece
func _on_Piece_input_event(_viewport, _event, _shape_idx):
	# Double clicks cause extra events
	# So add the !selected to make sure it ignores the extras
	if Input.is_action_just_pressed("click") and !selected:
		selected = true
		# This signal goes to the parent
		emit_signal("is_selected")
		
		homie = get_parent().position

# This separate input event function is to handle releasing button
func _input(event):
	# Needs the echo check for same reason as above
	if event is InputEventMouseButton and not event.is_echo():
		# Need a check for selected because otherwise ALL pawns
		# will move when 1 is.
		if selected:
			selected = false
			emit_signal("is_dropped")
		else:
			pass

# The function for moving the piece, must update the board
func move_piece(new_tile,id):
# warning-ignore:unassigned_variable
# Need current tile before updating the screen position to pass
# to the update signal
	var current_tile: Vector2
	current_tile.x = floor(homie.x/TILE_SIZE)
	current_tile.y = floor(homie.y/TILE_SIZE)
	# Update homie so that the lock position works
	homie = TILE_SIZE*Vector2((2*new_tile.x +1)/2,(2*new_tile.y +1)/2)
	# capture possible pieces
	if get_overlapping_areas():
		emit_signal('capture',get_overlapping_areas()[0])
	
	# Update board_state
	emit_signal("update_board",current_tile,new_tile,id)
