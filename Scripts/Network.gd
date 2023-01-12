extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 7898
const PLAYERS = 2

var players = { }
var self_data = {name = ''}

var white_team:= true

var external_ip: String
var upnp = UPNP.new()

signal update_board(current_tile,new_tile,id)
signal team_change
signal blue_team_test
signal white_team_test


func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_disconnected', self, '_player_disconnected')
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected',self,'_player_connected')
# warning-ignore:return_value_discarded
	get_tree().connect('connected_to_server', self, '_connected_to_server')
# warning-ignore:return_value_discarded
	get_tree().connect('connection_failed',self,'_connection_failure')
# warning-ignore:return_value_discarded
	get_tree().connect('server_disconnected',self,'_server_disconnect')
	# Use upnp to find ports
	var discover_result = upnp.discover()
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		var gateway = upnp.get_gateway()
		if gateway and gateway.is_valid_gateway():
			var map_result_udp = gateway.add_port_mapping(DEFAULT_PORT,DEFAULT_PORT,"godot_udp","UDP",0)
			var map_result_tcp = gateway.add_port_mapping(DEFAULT_PORT,DEFAULT_PORT,"godot_tcp","TCP",0)
			
			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT,DEFAULT_PORT,"","UDP")
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(DEFAULT_PORT,DEFAULT_PORT,"","TCP")
	external_ip = upnp.query_external_address()
	print(external_ip)
	
func host():
	players[1] = self_data
	var server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,PLAYERS)
	get_tree().set_network_peer(server)
	

func connect_to_server(ip_address):
	var peer = NetworkedMultiplayerENet.new()
	
	peer.create_client(ip_address,DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	# This function needs to set_network_master on blue team pieces only.

func _connected_to_server():
	print('connected to server call')
	players[get_tree().get_network_unique_id()] = self_data
	print(players)
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)

func _player_connected(id):
	print('Player' + str(id) + 'connected')
	Globals.otherPlayerId = id

func _player_disconnected(id):
	# Check that this is all necessary
	print('Player' + str(id) + 'disconnected')
	players.erase(id)

func animate_move(tile1,tile2,piece_id):
	# This should be called along with update_board signals
	# After a player makes their move and updates their board locally
	# They need to pass the turn.  This function should animate move
	# for the other player. On local scene, this is only for castling
	var pos1 = Globals.tile_2_xy(tile1)
	var pos2 = Globals.tile_2_xy(tile2)
	piece_id.piece.homie.x = lerp(pos1.x,pos2.x,1)
	piece_id.current_tile = tile2
	

remote func send_board_update(old_tile,new_tile,piece_id):
	emit_signal("update_board",old_tile,new_tile,piece_id)

func pass_turn():
	white_team = !white_team
	emit_signal("team_change")
	



func _connection_failure():
	print('Connection failed!')

func _server_disconnect():
	print('Server disconnected.')
