extends CanvasLayer

@onready var MainMenu = %MainMenu
@onready var HostingInterface = %HostingInterface
@onready var JoiningInterface = %JoiningInterface
@onready var Settings = %Settings


func _on_networking_server_created():
	pass # Replace with function body.


func _on_host_button_pressed_from_MainMenu():
	MainMenu.hide()
	HostingInterface.show()


func _on_switch_menu(nodepath, target_nodepath):
	var node = get_node(nodepath)
	var target_node = get_node(target_nodepath)
	target_node.show()
	node.hide()
	
	print("UI-Event: ", node.name, " -> ", target_node.name)
