extends Node

var players = {}
var player_info = {}
var my_info = "Unnamed"

var server_port = 7777
var server_adress = "localhost"
var max_peers = 8
var peer_id
var initializied = false

@onready var peer_list = %PeerList
@onready var lobby_peer = preload("res://lobby_peer.tscn")
@onready var network_adress = func get_ip4():
	var ip = "localhost"
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip = address
	
	return ip


func _setup():
	if !initializied:
		multiplayer.multiplayer_peer.peer_connected.connect(_peer_connected)
		multiplayer.multiplayer_peer.peer_disconnected.connect(_peer_disconnected)
		multiplayer.connection_failed.connect(_connection_failed)
		multiplayer.server_disconnected.connect(_server_disconnected)
		multiplayer.connected_to_server.connect(_connected_ok)
		initializied = true


func _on_host_button_pressed():
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_server(server_port)
	multiplayer.multiplayer_peer = enet_peer
	_setup()
	peer_id = enet_peer.get_unique_id()
	update_peer_list(peer_id, my_info)


func update_peer_list(id, username):
	var new_peer = lobby_peer.instantiate()
	peer_list.add_child(new_peer)
	new_peer.name = str(id)
	new_peer.get_child(0).get_child(0).get_child(0).get_child(1).text = "[Id: %s]" %str(id)
	if id == 1:
		new_peer.get_child(0).get_child(0).get_child(0).get_child(2).text = "Host:"
	else:
		new_peer.get_child(0).get_child(0).get_child(0).get_child(2).text = "User:"
	new_peer.get_child(0).get_child(0).get_child(0).get_child(3).text = str(username)
	print("[Networking-Event]: ", "New peer added. Id: %s" %new_peer.name)


func _on_join_button_pressed():
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_client(server_adress, server_port)
	multiplayer.multiplayer_peer = enet_peer
	peer_id = enet_peer.get_unique_id()
	await get_tree().create_timer(0.2).timeout
	update_peer_list(enet_peer.get_unique_id(), my_info)


func _peer_connected(id):
	print("[Networking-Event]: ", "Peer: %s connected." %str(id))
	await get_tree().create_timer(0.1).timeout
	update_peer_list(id, my_info)
	rpc("register_player", my_info)


@rpc
func register_player(info):
	var id = multiplayer.get_remote_sender_id()
	player_info[id] = info
	update_peer_list(id, info)


func _peer_disconnected(id):
	player_info.erase(id)
	peer_list.get_node(str(id)).queue_free()
	print("[Networking-Event]: ", "Peer: %s disconnected." %str(id))


func _connection_failed():
	print("[Networking-Event]: ", "Failed to connect.")


func _server_disconnected():
	print("[Networking-Event]: ", "Server disconnected.")


func _connected_ok():
	print("[Networking-Event]: ", "Succesfully connected.")


func _on_leave_lobby_button_pressed():
	multiplayer.multiplayer_peer.close()
	#_peer_disconnected(peer_id)
	var l = 0
	for i in peer_list.get_child_count():
		peer_list.get_child(i).queue_free()
		l += 1
	print("[CleanUp-Event]: ", "Deleted %s unused children." %l)
