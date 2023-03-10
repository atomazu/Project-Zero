extends Node


var peer_id = 0
var peer_list = {}
@onready var peer_box = %PeerBox
@onready var lobby_peer = preload("res://scenes/lobby_peer.tscn")


func _on_create_server():
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_server(9999, 16)
	multiplayer.multiplayer_peer = enet_peer
	peer_id = enet_peer.get_unique_id()
	Global.set_up_network_signals(self)
	
	print("[Networking-Event]: ", "Server created.")
	Global.add_peer(peer_id, peer_box, lobby_peer, peer_list)


func _peer_connected(id):
	print("[Client: %s]: "  %id, "Connected.")
	Global.add_peer(id, peer_box, lobby_peer)
	sync_clients()


func _peer_disconnected(id):
	print("[Client: %s]: "  %id, "Disconnected.")
	Global.remove_peer(id, peer_box)
	sync_clients()


func _on_connected_to_server():
	print("[Networking-Event]: ", "Connected to server.")
	sync_clients()


func _on_connection_failed():
	print("[Networking-Event]: ", "Failed to connect to server.")


func _connection_failed():
	print("[Networking-Event]: ", "Failed to connect.")


func _server_disconnected():
	print("[Networking-Event]: ", "Server disconnected.")
	for peer in peer_list:
		Global.remove_peer(peer, peer_box, peer_list)


@rpc("any_peer")
func sync_clients():
	if peer_list.size() > 1:
		rpc("sync_client", peer_list)
		print("[Server]: ", "Clients synced.")


@rpc("any_peer")
func sync_client():
	print("[Server]: ", "Clients synced.")


func _on_close_server():
	multiplayer.multiplayer_peer = null
	Global.clear_child_nodes(peer_box, peer_list)
	print("[Networking-Event]: ", "Server closed.")
	peer_id = null
	print("---------------------------------------\n",
		"[GAME]: ", "Scene Reloaded.\n",
		"---------------------------------------")
	Global.reload_game()
