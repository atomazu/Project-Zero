extends VBoxContainer

@onready var world_enviroment = %WorldEnvironment
@onready var window_size = DisplayServer.window_get_size()

@onready var antialiasing_quality = "OFF"
@onready var ssao_quality = "OFF"
@onready var bloom_strength = "OFF"
@onready var ss_reflection_quality = "OFF"
@onready var window_mode = "WINDOWED"


func _ready():
	load_settings()

func _on_resolution_button_item_selected(index):
	if index == 0:
		window_size = Vector2(1280, 720)
	elif index == 1:
		window_size = Vector2(1920, 1080)
	elif index == 2:
		window_size = Vector2(2560, 1440)
	elif index == 3:
		window_size = Vector2(3840, 2160)


func _on_antialiasing_button_item_selected(index):
	if index == 0:
		antialiasing_quality = "OFF"
	elif index == 1:
		antialiasing_quality = "FXAA"
	elif index == 2:
		antialiasing_quality = "MSAA 2x"
	elif index == 3:
		antialiasing_quality = "MSAA 4x"
	elif index == 4:
		antialiasing_quality = "MSAA 8x"


func _on_ssao_button_item_selected(index):
	if index == 0:
		ssao_quality = "OFF"
	elif index == 1:
		ssao_quality = "LOW"
	elif index == 2:
		ssao_quality = "MEDIUM"

func _on_bloom_button_item_selected(index):
	if index == 0:
		bloom_strength = "OFF"
	elif index == 1:
		bloom_strength = "LOW"
	elif index == 2:
		bloom_strength = "MEDIUM"


func _on_ss_reflection_button_item_selected(index):
	if index == 0:
		ss_reflection_quality = "OFF"
	elif index == 1:
		ss_reflection_quality = "LOW"
	elif index == 2:
		ss_reflection_quality = "MEDIUM"
	elif index == 2:
		ss_reflection_quality = "HIGH"
	elif index == 4:
		ss_reflection_quality = "ULTRA"


func _on_window_mode_button_item_selected(index):
	if index == 0:
		window_mode = "WINDOWED"
	elif index == 1:
		window_mode = "FULLSCREEN"


func _on_apply_button_pressed():
	#Resolution
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_position((DisplayServer.screen_get_size() - DisplayServer.window_get_size()) * 0.5)
	
	#Antialiasing
	match antialiasing_quality:
		"OFF":
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"FXAA":
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		"MSAA 2x":
			get_viewport().msaa_3d = Viewport.MSAA_2X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"MSAA 4x":
			get_viewport().msaa_3d = Viewport.MSAA_4X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"MSAA 8x":
			get_viewport().msaa_3d = Viewport.MSAA_8X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	
	match ssao_quality:
		"OFF":
			world_enviroment.environment.set_ssao_enabled(false)
		"LOW":
			world_enviroment.environment.set_ssao_enabled(true)
			world_enviroment.environment.set_ssao_detail(0.5)
		"MEDIUM":
			world_enviroment.environment.set_ssao_enabled(true)
			world_enviroment.environment.set_ssao_detail(0.8)
	
	match bloom_strength:
		"OFF":
			world_enviroment.environment.glow_enabled = false
			world_enviroment.environment.glow_bloom = 0
		"LOW":
			world_enviroment.environment.glow_enabled = true
			world_enviroment.environment.glow_bloom = 0.5
		"MEDIUM":
			world_enviroment.environment.glow_enabled = true
			world_enviroment.environment.glow_bloom = 1
	
	match ss_reflection_quality:
		"OFF":
			world_enviroment.environment.ssr_enabled = false
		"LOW":
			world_enviroment.environment.ssr_enabled = true
			world_enviroment.environment.ssr_max_steps = 16
		"MEDIUM":
			world_enviroment.environment.ssr_enabled = true
			world_enviroment.environment.ssr_max_steps = 32
		"HIGH":
			world_enviroment.environment.ssr_enabled = true
			world_enviroment.environment.ssr_max_steps = 64
		"ULTRA":
			world_enviroment.environment.ssr_enabled = true
			world_enviroment.environment.ssr_max_steps = 128
	
	match window_mode:
		"WINDOWED":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"FULLSCREEN":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	save_settings()
	
#debug
	print("[Settings-Event]: ", "antialiasing_quality: %s" %str(antialiasing_quality))
	print("[Graphics-Event]: ", "ssao_quality: %s" %str(ssao_quality))
	print("[Settings-Event]: ", "bloom_strength: %s" %str(bloom_strength))
	print("[Settings-Event]: ", "ss_reflection_quality: %s" %str(ss_reflection_quality))
	print("[Settings-Event]: ", "window_size: %s" %str(window_size))
	print("[Settings-Event]: ", "window_mode: %s" %str(window_mode))


func save_settings():
	var save_data = {
		"window_size": $GridContainer/ResolutionButton.selected,
		"antialiasing_quality": $GridContainer/AntialiasingButton.selected,
		"ssao_quality": $GridContainer/SSAOButton.selected,
		"bloom_strength": $GridContainer/BloomButton.selected,
		"ss_reflection_quality": $GridContainer/SSReflectionButton.selected,
		"window_mode": $GridContainer/WindowModeButton.selected
	}
	
	var file = FileAccess.open("user://project_zero.save", FileAccess.WRITE)
	file.store_var(save_data)


func load_settings():
	var file = FileAccess.open("user://project_zero.save", FileAccess.READ)
	if file:
		var load_data = file.get_var()
	
		_on_resolution_button_item_selected(load_data["window_size"])
		_on_antialiasing_button_item_selected(load_data["antialiasing_quality"])
		_on_ssao_button_item_selected(load_data["ssao_quality"])
		_on_bloom_button_item_selected(load_data["bloom_strength"])
		_on_ss_reflection_button_item_selected(load_data["ss_reflection_quality"])
		_on_window_mode_button_item_selected(load_data["window_mode"])
		
		$GridContainer/ResolutionButton.selected = load_data["window_size"]
		$GridContainer/AntialiasingButton.selected = load_data["antialiasing_quality"]
		$GridContainer/SSAOButton.selected = load_data["ssao_quality"]
		$GridContainer/BloomButton.selected = load_data["bloom_strength"]
		$GridContainer/SSReflectionButton.selected = load_data["ss_reflection_quality"]
		$GridContainer/WindowModeButton.selected = load_data["window_mode"]
		
		print("[Settings-Event]: ", "Settings Loaded: ", load_data)
	
	_on_apply_button_pressed()
