extends CanvasLayer

@onready var MainMenu = %MainMenu
@onready var HostingInterface = %HostingInterface
@onready var JoiningInterface = %JoiningInterface
@onready var Settings = %Settings


func _on_switch_menu(nodepath : NodePath, target_nodepath : NodePath, function : String = ""):
	var node = get_node(nodepath)
	var target_node = get_node(target_nodepath)
	target_node.show()
	node.hide()
	
	if function != "":
		match function:
			"create_server":
				Global.server.start()
			"create_client":
				Global.client.start()
			"lobby_leave":
				if multiplayer.multiplayer_peer.get_connection_status() != 0:
					if multiplayer.multiplayer_peer.get_connection_status() != 1:
						if multiplayer.is_server():
							Global.server.close()
						else:
							Global.client.close()
	
	print("[UI-Event]: ", node.name, " -> ", target_node.name)


func _on_exit_button_pressed():
	get_tree().quit()
