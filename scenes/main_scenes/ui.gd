extends CanvasLayer

@onready var player_health_bar = get_node("HUD/InfoContainer/HBoxContainer/PlayerHealthBar")

var health_bars_visible = false

func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://scenes/towers/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	
	var range_texture = Sprite2D.new()
	range_texture.set_name("TowerRangeOverlay")
	var scaling = GameData.tower_data[tower_type]["range"] / 600.0
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://assets/towers/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color("ad54ff3c")
	
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.set_position(mouse_position)
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0)
	
func update_tower_preview(new_pos, color):
	get_node("TowerPreview").set_position(new_pos)
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node(("TowerPreview/TowerRangeOverlay")).modulate = Color(color)


func update_player_health_bar(player_health):
	player_health_bar.value = player_health

##
## Game Control
##

func _on_play_pause_button_pressed():
	if get_parent().construction_mode:
		get_parent().cancel_construction_mode()

	if get_tree().is_paused():
		get_tree().paused = false 
	elif get_parent().current_wave == 0:
		get_parent().current_wave += 1
		get_parent().start_next_wave()
	else:
		get_tree().paused = true


func _on_fast_forward_button_pressed():
	if get_parent().construction_mode:
		get_parent().cancel_construction_mode()

	if Engine.get_time_scale() == 1.0:
		Engine.set_time_scale(2.0)
	elif Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(5.0)
	else:
		Engine.set_time_scale(1.0)

func _input(event):
	if (Input.is_key_pressed(KEY_ALT)):
		health_bars_visible = not health_bars_visible
