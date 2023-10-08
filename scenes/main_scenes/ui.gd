extends CanvasLayer

@onready var player_health_bar = get_node("HUD/InfoContainer/HBoxContainer/HealthInfo/PlayerHealthBar")
@onready var player_money_label = get_node("HUD/InfoContainer/HBoxContainer/MoneyInfo/MoneyLabel")
@onready var current_wave_label = get_node("HUD/InfoContainer/HBoxContainer/WaveInfo/WaveCounter")
@onready var countdown_next_wave_label = get_node("HUD/InfoContainer/HBoxContainer/NextWaveCountdown/Countdown")
@onready var remaining_mobs_label = get_node("HUD/InfoContainer/HBoxContainer/WaveInfo/RemainingMobs")
# Game Over
@onready var game_over_container = get_node("HUD/GameOverContainer")
@onready var game_over_waves_survived_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/WavesSurvivedValue")
@onready var game_over_mobs_killed_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/MobsKilledValue")
@onready var game_over_money_spent_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/MoneySpentValue")
@onready var game_over_xp_gain_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/XPGainValue")

var health_bars_visible = false
var range_indicators_visible = false

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

func show_game_over(waves_survived, mobs_killed, money_spent, player_money):
	game_over_waves_survived_value.text = str(waves_survived)
	game_over_mobs_killed_value.text = str(mobs_killed)
	game_over_money_spent_value.text = str(money_spent)
	game_over_xp_gain_value.text = str(player_money * 0.1)
	game_over_container.visible = true
##
## Game Control
##

func _on_play_pause_button_pressed():
	if get_parent().construction_mode:
		get_parent().cancel_construction_mode()

	if get_tree().is_paused():
		get_tree().paused = false 
	elif get_parent().current_wave == 0:
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
	if (Input.is_key_pressed(KEY_CTRL)):
		range_indicators_visible = not range_indicators_visible

##
## HUD: Infobar
##

func update_player_health_bar(player_health):
	player_health_bar.value = player_health

func update_player_money_label(player_money):
	player_money_label.text = str(player_money)
	
func update_wave_counter(current_wave):
	current_wave_label.text = "Current Wave: " + str(current_wave)

func update_remaining_mobs(remaining_mobs):
	remaining_mobs_label.text = "Remaining mobs: " + str(remaining_mobs)

func create_next_wave_countdown_label():
	countdown_next_wave_label.visible = true

func destroy_next_wave_countdown_label():
	countdown_next_wave_label.visible = false

func update_next_wave_countdown_label(sec):
	if sec <= 3:
		countdown_next_wave_label.set_modulate(Color("fb1a2f"))
	else: 
		countdown_next_wave_label.set_modulate(Color("ffffff"))
	countdown_next_wave_label.text = "Next Wave in: " + str(sec)

func show_insufficient_money():
	player_money_label.set_modulate(Color("fb1a2f"))
	await get_tree().create_timer(0.3).timeout
	player_money_label.set_modulate(Color("ffffff"))
