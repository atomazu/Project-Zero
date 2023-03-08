extends Node


const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var Player = load("res://player/Player.tscn")
signal server_created


# main stuff
func _ready():
	pass


# connections
func _on_host_button_pressed():
	print("---------------------------------------")
	print("[Networking-Event]: ", "Attempting to create server...")
	var ip4 = get_ip4()
	
	enet_peer.create_server(PORT)
	enet_peer.set_bind_ip(ip4)
	
	multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(player_jon)
	#multiplayer.peer_disconnected.connect(player_disconnect)
	
	print("[Networking-Event]: ", "Server created.\n",
		"[Networking-Event]: ","Ip: %s\n" % ip4,
		"[Networking-Event]: ","Port: %s\n" % PORT,
		"---------------------------------------")
	
	#add_player(multiplayer.get_unique_id())
	server_created.emit()


func _on_join_button_pressed():
	var adress_entry = %CustomIp
	var port_entry = %CustomPort
	
	print("[Networking-Event]: ", "Attempting to join server...")
	
	if adress_entry.text and port_entry.text:
		enet_peer.create_client(adress_entry.text, port_entry.text)
	elif adress_entry.text:
		enet_peer.create_client(adress_entry.text, PORT)
	elif port_entry.text:
		print("[Networking-Event]: ", "Couldn't find server. Attempting to join localhost...")
		enet_peer.create_client("localhost", port_entry.text)
	else:
		print("[Networking-Event]: ", "Couldn't find server. Attempting to join localhost...")
		enet_peer.create_client("localhost", PORT)
	
	if enet_peer:
		multiplayer.multiplayer_peer = enet_peer
		print("[Networking-Event]: ", "Multiplayer peer assigned to enet_peer.")
	


func on_multiplayer_connection_failed():
	assert("[Networking-Event]: ", "Server Connection couldn't be established.")


func _on_exit_button_pressed():
	get_tree().quit()


# custom functions
func get_ip4():
	var ip = "localhost"
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip = address
	
	return ip


func add_player_instance(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	print("[Networking-Event]: ", "Player added succesfully.")


func remove_player_instance(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		print("[Networking-Event]: ", "Player %s removed succesfully." %player.name)
		player.queue_free()
	else:
		print("[Networking-Event]: ", "Player couldn't be found and thus not be removed.")


func _on_leave_lobby_button_pressed():
	pass # Replace with function body.
