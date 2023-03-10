extends Node
var game_preload = preload("res://game.tscn")

func get_ip4():
	var ip = "localhost"
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip = address
	
	return ip


func add_peer(peer, parent, scene, dict : Dictionary = {}):
	if !dict.is_empty():
		dict[peer] = peer
	var new_peer = scene.instantiate()
	parent.add_child(new_peer)
	new_peer.name = str(peer)
	print("[Client: %s]: " %peer, "Added: %s at" %peer, "%s." %parent, "Also added their entry to %s" %dict)


func remove_peer(peer, parent : Node, dict : Dictionary = {}, show_debug : bool = false):
	if !dict.is_empty():
		dict.erase(peer)
	parent.get_node(str(peer)).queue_free()
	if show_debug:
		print("[Client: %s]: " %peer, "Deleted peer: %s from" %peer, "%s." %parent, "Also cleared their entry from %s" %dict)


func clear_child_nodes(parent : Node, dict : Dictionary = {}):
	var delete_children = 0
	for peer in parent.get_children():
		remove_peer(peer, parent, dict)
		delete_children += 1
	if delete_children == 1:
		print("[Local]: ", "Successfully deleted %s child from " %delete_children, parent.name, ".")
	else:
		print("[Local]: ", "Successfully deleted %s children from " %delete_children, parent.name, ".")


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


func reload_game():
	var game = get_tree().get_root().get_child(1)
	get_tree().queue_delete(game)
	var new_game = game_preload.instantiate()
	get_tree().get_root().add_child(new_game)
