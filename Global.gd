extends Node

@onready var server = Server.new()
@onready var client = Client.new()
@onready var game = get_tree().get_root().get_child(1)
@onready var lobby = game.get_node("%Lobby")
@onready var peer_box = game.get_node("LocalUserInterface/Lobby/MainPanel/MarginContainer/VBoxContainer/PeerBox")
@onready var lobby_peer_preload = preload("res://scenes/lobby_peer.tscn")
@onready var peer_box_preload = preload("res://peer_box.tscn")
var setup = false


func _ready():
	add_child(server)
	add_child(client)


func set_up_network_signals(node : Node):
	if !setup:
		setup = true
		multiplayer.connected_to_server.connect(node._on_connected_to_server)
		multiplayer.connection_failed.connect(node._on_connection_failed)
		multiplayer.multiplayer_peer.peer_connected.connect(node._peer_connected)
		multiplayer.multiplayer_peer.peer_disconnected.connect(node._peer_disconnected)
		multiplayer.connection_failed.connect(node._connection_failed)
		multiplayer.server_disconnected.connect(node._server_disconnected)

@rpc("authority", "call_local")
func update_client_list(client_list, id):
	client.client_list = client_list
	add_peer_to_lobby_box(client_list, id)
	print("[Global.gd]: ", "Updated client list.")


func snyc_peer_list(client_list, id):
	rpc("update_client_list", client_list, id)


func ready_to_receive():
	rpc_id(1, "add_already_connected_peers")


@rpc("authority")
func remove_peer(id):
	if multiplayer.is_server() and server.client_list.size() > 1:
		rpc("remove_peer")
	peer_box.get_node(str(id)).queue_free()
	print("[Global.gd]: {Client-%s}" %id, " removed from server.")


@rpc("any_peer")
func add_already_connected_peers(client_list : Dictionary = {}, peer_id = 0):
	if multiplayer.is_server():
		rpc_id(server.last_connected, "add_already_connected_peers", server.client_list)
		print("[Global.gd]: ", "Added already connected clients to {Client-%s}." %server.last_connected)
	else:
		for id in client_list:
			add_peer_to_lobby_box(client_list, id, client.peer_id)


func add_peer_to_lobby_box(client_list, id, from = 0):
		print("[Global.gd]: ", "Added {Client-%s}" %id, " to {Client-%s}." %from)
		var lobby_peer = lobby_peer_preload.instantiate()
		peer_box.add_child(lobby_peer)
		lobby_peer.name = str(id)
		lobby_peer.get_node("MarginContainer/HBoxContainer/PeerInfo/PeerId").text = str("(%s)" %str(id))
		lobby_peer.get_node("MarginContainer/HBoxContainer/PeerInfo/Username").text = str(client_list[id]["username"])


func reload_game():
	var window_pos = DisplayServer.window_get_position()
	var window_size = DisplayServer.window_get_size()
	get_tree().reload_current_scene()
	DisplayServer.window_set_position(window_pos)
	DisplayServer.window_set_size(window_size)
