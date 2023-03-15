extends Node
class_name Client

@onready var game = get_tree().get_root().get_child(1)
@onready var lobby = game.get_node("%Lobby")
@onready var peer_box = game.get_node("%PeerBox")
@onready var lobby_peer = preload("res://scenes/lobby_peer.tscn")


var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var server_ip : String = "127.0.0.1"
var server_port : int = 9999
var client_list = {}
var peer_id = 0
 
var username : String = "Client"


func start():
	enet_peer.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = enet_peer
	Global.set_up_network_signals(self)
	
	peer_id = enet_peer.get_unique_id()

func close():
	multiplayer.multiplayer_peer.close()
	print("[Client-%s]: " %peer_id, "disconnected (you).")
	Global.reload_game()


func update_peer_box(id):
	client_list[id] = {"username": str(id), "ready": false}
	Global.send_client_list(client_list)
	Global.update_lobby(client_list, id)


func _on_connected_to_server():
	await get_tree().create_timer(0.2).timeout
	print("[Client-%s]: " %peer_id, "ready to receive.")
	Global.ready_to_receive()


func _on_connection_failed():
	pass


func _peer_connected(_id):
	pass


func _peer_disconnected(_id):
	pass


func _connection_failed():
	multiplayer.multiplayer_peer.close()
	print("[Client-%s]: " %peer_id, "disconnected (you).")
	Global.reload_game()


func _server_disconnected():
	multiplayer.multiplayer_peer.close()
	print("[Client-%s]: " %peer_id, "disconnected (you).")
	Global.reload_game()
