extends Node

func _ready():
	load_main_menu()

func load_main_menu():
	var new_game_button = get_node("MainMenu/MarginContainer/VBoxContainer/NewGameButton")
	new_game_button.connect("pressed", on_new_game_pressed)
	var quit_button = get_node("MainMenu/MarginContainer/VBoxContainer/QuitButton")	
	quit_button.connect("pressed", on_quit_pressed)

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://scenes/main_scenes/game_scene.tscn").instantiate()
	game_scene.connect("game_over", unload_map)
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()
	
func unload_map(result):
	get_node("GameScene").queue_free()
	var main_menu = load("res://scenes/ui_scenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()
