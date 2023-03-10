extends CanvasLayer

@onready var MainMenu = %MainMenu
@onready var HostingInterface = %HostingInterface
@onready var JoiningInterface = %JoiningInterface
@onready var Settings = %Settings

signal _on_create_server
signal _on_create_client
signal _on_client_leave
signal _on_close_server


func _on_host_button_pressed_from_MainMenu():
	MainMenu.hide()
	HostingInterface.show()


func _on_switch_menu(nodepath, target_nodepath, emit_signal_ = ""):
	var node = get_node(nodepath)
	var target_node = get_node(target_nodepath)
	target_node.show()
	node.hide()
	
	if !emit_signal_.is_empty():
		match emit_signal_:
			"create_server":
				emit_signal("_on_create_server")
			"create_client":
				emit_signal("_on_create_client")
			"lobby_leave":
				if multiplayer.is_server():
					emit_signal("_on_close_server")
				else:
					emit_signal("_on_client_leave")
	
	print("[UI-Event]: ", node.name, " -> ", target_node.name)


func _on_exit_button_pressed():
	get_tree().quit()
