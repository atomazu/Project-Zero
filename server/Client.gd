extends Node


var peer_id = 0
var peer_list = {}
@onready var peer_box = %PeerBox
@onready var lobby_peer = preload("res://scenes/lobby_peer.tscn")


func _on_create_client():
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_client("localhost" ,9999)
	multiplayer.multiplayer_peer = enet_peer
	peer_id = enet_peer.get_unique_id()
	Global.set_up_network_signals(self)
	
	print("[Networking-Event]: ", "Client created with id: %s." %peer_id)


func _peer_connected(id):
	print("[Client: %s]: "  %id, "Connected.")
	Global.add_peer(id, peer_box, lobby_peer, peer_list)


func _peer_disconnected(id):
	print("[Networking-Event]: ", "Peer disconnected: %s" %id)
	Global.remove_peer(id, peer_box, peer_list)


func _on_connected_to_server():
	print("[Client: %s]: "  %peer_id, "Connected to server.")
	Global.add_peer(peer_id, peer_box, lobby_peer, peer_list)


func _on_connection_failed():
	print("[Client: %s]: "  %peer_id, "Failed to connect to server.")


func _connection_failed():
	print("[Networking-Event]: ", "Failed to connect.")


func _server_disconnected():
	print("[Networking-Event]: ", "Server disconnected.")
	_on_client_leave()
	%LocalUserInterface._on_switch_menu("%Lobby", "%MainMenu")
	Global.display_error("Server disconnected.", "Host closed the game or had a disconnect.", %ErrorPopUp)


@rpc("authority", "call_remote")
func sync_client(server_peer_list):
	var missing_peers = {}
	for peer in server_peer_list:
		if not peer_list.has(peer):
			Global.add_peer(peer, peer_box, lobby_peer, peer_list)
	if !missing_peers.is_empty():
		print("[Client: %s]: ", "synced peer list with server.\n",
				"[Client: %s]: ", "Difference: ", missing_peers)


func _on_client_leave():
	Global.clear_child_nodes(peer_box, peer_list)
	multiplayer.multiplayer_peer = null
	peer_id = null
	print("---------------------------------------\n",
		"[GAME]: ", "Scene Reloaded.\n",
		"---------------------------------------")
	Global.reload_game()
