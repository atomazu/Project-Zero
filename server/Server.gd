extends Node
class_name Server

@onready var game = get_tree().get_root().get_child(1)
@onready var lobby = game.get_node("%Lobby")
@onready var peer_box = game.get_node("%PeerBox")
@onready var lobby_peer = preload("res://scenes/lobby_peer.tscn")


var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int = 9999
var max_clients = 8
var client_list = {}

var username = "Server"
var peer_id = 1
var last_connected = 1


func start():
	enet_peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = enet_peer
	Global.set_up_network_signals(self)
	
	print("[Server]: ", "Server started.")
	
	client_list[peer_id] = {"username": username, "ready": false}
	Global.add_peer_to_lobby_box(client_list, peer_id)


func close():
	multiplayer.multiplayer_peer.close()
	print("[Server]: ", "reloaded scene.")
	Global.reload_game()


func _peer_connected(id):
	print("[Server]: ", id, " connected.")
	client_list[id] = {"username": "unnamed", "ready": false}
	Global.snyc_peer_list(client_list, id)
	last_connected = id


func _peer_disconnected(id):
	print("[Server]: ", id, " disconnected.")
	client_list.erase(id)
	Global.remove_peer(id)


func _on_connected_to_server():
	pass


func _on_connection_failed():
	pass


func _connection_failed():
	pass


func _server_disconnected():
	pass
