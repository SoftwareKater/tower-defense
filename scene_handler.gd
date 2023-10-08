extends Node

func _ready():
	load_main_menu()

func load_main_menu():
	var new_game_button = get_node("MainMenu/MarginContainer/VBoxContainer/NewGameButton")
	new_game_button.connect("pressed", on_new_game_pressed)
	var quit_button = get_node("MainMenu/MarginContainer/VBoxContainer/QuitButton")	
	quit_button.connect("pressed", on_quit_pressed)

func load_map_selection_menu():
	var select_map_1_button = get_node("MapSelectionMenu/MarginContainer/FlowContainer/Map1/Start")
	select_map_1_button.connect("pressed", on_map_selected_pressed.bind("map_1"))
	var select_map_desert_a_button = get_node("MapSelectionMenu/MarginContainer/FlowContainer/MapDesertA/Start")
	select_map_desert_a_button.connect("pressed", on_map_selected_pressed.bind("map_desert_a"))

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var map_selection_menu = load("res://scenes/ui_scenes/map_selection_menu.tscn").instantiate()
	add_child(map_selection_menu)
	load_map_selection_menu()
	pass
	# go to map selection

func on_map_selected_pressed(map_name):
	get_node("MapSelectionMenu").queue_free()
	var game_scene = load("res://scenes/main_scenes/game_scene.tscn").instantiate()
	var map = load("res://scenes/maps/" + map_name + ".tscn").instantiate()
	game_scene.add_child(map)
	move_child(map, 0)
	map.set_name("Map")
	game_scene.current_map = map_name
	game_scene.connect("game_over", unload_map)
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()
	
func unload_map(result):
	get_node("GameScene").queue_free()
	var main_menu = load("res://scenes/ui_scenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()
