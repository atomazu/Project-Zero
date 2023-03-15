extends Node
var joining_interface
var hosting_interface
@onready var lobby_peer = preload("res://scenes/lobby_peer.tscn")

func _ready():
	print("joining_interface: ", joining_interface)
	print("hosting_interface: ", hosting_interface)

func get_ip4():
	var ip = "localhost"
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip = address
	
	return ip


func set_interfaces(joining_interface_node, hosting_interface_node):
	joining_interface = joining_interface_node
	hosting_interface = hosting_interface_node


func add_peer(peer : ClientInfo, parent : Node, scene : PackedScene):
	var new_peer = scene.instantiate()
	parent.add_child(new_peer)
	new_peer.name = str(peer)


func remove_peer(peer, parent : Node, dict : Dictionary = {}, show_debug : bool = false):
	if !dict.is_empty():
		dict.erase(peer)
	parent.get_node(str(peer)).queue_free()
	if show_debug:
		print("[Client: %s]: " %peer, "Deleted peer: %s from " %peer, "%s." %parent)


func clear_child_nodes(parent : Node, dict : Dictionary = {}):
	var deleted_children = 0
	for peer in parent.get_children():
		remove_peer(peer, parent, dict)
		deleted_children += 1
	if deleted_children == 1:
		print("[Local]: ", "Successfully killed %s's child from " %deleted_children, parent.name, ".")
	else:
		print("[Local]: ", "Successfully killed %s's children from " %deleted_children, parent.name, ".")


func set_up_network_signals(node : Node):
	multiplayer.connected_to_server.connect(node._on_connected_to_server)
	multiplayer.connection_failed.connect(node._on_connection_failed)
	multiplayer.multiplayer_peer.peer_connected.connect(node._peer_connected)
	multiplayer.multiplayer_peer.peer_disconnected.connect(node._peer_disconnected)
	multiplayer.connection_failed.connect(node._connection_failed)
	multiplayer.server_disconnected.connect(node._server_disconnected)


func display_error(title : String, message : String, window : Control):
	var VBox = window.get_child(0).get_child(0).get_child(0)
	var content = VBox.get_child(1)
	var header = VBox.get_child(0).get_child(0)
	
	header.text = title
	content.text = message
	window.show()


func display_debug(debug_window : Control, debug_info = null):
	if debug_info:
		var VBox = debug_window.get_child(0).get_child(0).get_child(0)
		var content = VBox.get_child(2)
		var header = VBox.get_child(0).get_child(0)
		header.text = "Debug Window"
		content.text = str(debug_info)
		debug_window.show()


func update_peer_box(peer_list : Dictionary, peer_box : Node):
	# Loop through each key-value pair in the peer_list
	print(peer_list)
	for key in peer_list:
		# Check if the peer_box has a child with the same name as the key
		var child = peer_box.get_node_or_null(str(peer_list[key].id))
		if child == null:
			# If not, create a new child node with the key as its name
			add_peer(peer_list[key], peer_box, lobby_peer)
			child = lobby_peer.instantiate()
			# Add the child node to the peer_box
			peer_box.add_child(child)
			child.name = str(peer_list[key].id)
		# Do something with the value of the peer_list for this key
		# For example, set a property of the child node based on the value
		# This depends on what you want to do with your game logic
		# Here I just print it as an example
		print(peer_list[key])
	# Loop through each child of the peer_box
	for child in peer_box.get_children():
		# Check if the child's name is not in the peer_list keys
		if not peer_list.has(child.name):
			# If not, remove it from the peer_box
			peer_box.remove_child(child)
	


class ClientInfo:
	## enet_peer unique id
	var id : int = 0
	
	## the username the player game themselfs
	var username : String = "unnamed"
	
	## their node in the peer_box
	var lobby_node : Control = null
	
	## their ENetMultiplayerPeer
	var enet_peer : ENetMultiplayerPeer = null


@rpc("any_peer")
func send_peer_list(peer_list : Dictionary, client : ClientInfo):
	rpc("receive_peer_list", peer_list, client)
	print("SEND PEER LIST CALLED")


@rpc("any_peer")
func receive_peer_list(peer_list, client):
	if client.id == 1:
		joining_interface.peer_list = peer_list
		update_peer_box(joining_interface.peer_list, joining_interface.peer_box)
	else:
		print("RECEIVE PEER LIST ERROR: CLIENT ID IS NOT 1")
	print("RECEIVE PEER LIST CALLED")


@rpc("any_peer")
func get_peer_client_info(id):
	return rpc_id(id, "get_client_info")


@rpc("any_peer")
func get_client_info():
	return joining_interface.local_client_info
#client connected

#on server
#get client_info and add to client_list
#sync client list between peers

#client disconnected
#delete client_info from client_list
#snyc client list


func reload_game():
	var game_load = load("res://game.tscn")
	var window_pos = DisplayServer.window_get_position()
	var window_size = DisplayServer.window_get_size()
	var game = get_tree().get_root().get_child(1)
	get_tree().queue_delete(game)
	var new_game = game_load.instantiate()
	get_tree().get_root().add_child(new_game)
	DisplayServer.window_set_position(window_pos)
	DisplayServer.window_set_size(window_size)
