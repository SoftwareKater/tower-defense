extends CanvasLayer

# Game Over
@onready var game_over_container = get_node("HUD/GameOverContainer")
@onready var game_over_waves_survived_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/WavesSurvivedValue")
@onready var game_over_mobs_killed_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/MobsKilledValue")
@onready var game_over_money_spent_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/MoneySpentValue")
@onready var game_over_xp_gain_value = get_node("HUD/GameOverContainer/VBoxContainer/GameStats/XPGainValue")
# Sound
@onready var ui_sound_effects = get_node("/root/SceneHandler/UISoundEffects")

var TOWER_NAME_WHEN_DRAGGED = "DragTower"
var TOWER_COLOR_HEX_WHEN_DRAGGED = "ad54ff3c"
var TOWER_PREVIEW_NODE_NAME = "TowerPreview"
var TOWER_RANGE_INDICATOR_NODE_NAME = "TowerRangeOverlay"

var health_bars_visible = false
var range_indicators_visible = false

func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://scenes/towers/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name(TOWER_NAME_WHEN_DRAGGED)
	drag_tower.modulate = Color(TOWER_COLOR_HEX_WHEN_DRAGGED)
	
	var range_texture = get_range_overlay(tower_type)
	
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.set_position(mouse_position)
	control.set_name(TOWER_PREVIEW_NODE_NAME)
	add_child(control, true)
	move_child(get_node(TOWER_PREVIEW_NODE_NAME), 0)

func get_range_overlay(tower_type):
	var range_texture = Sprite2D.new()
	range_texture.set_name(TOWER_RANGE_INDICATOR_NODE_NAME)
	var scaling = GameData.tower_data[tower_type]["range"] / 600.0
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://assets/towers/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color(TOWER_COLOR_HEX_WHEN_DRAGGED)
	return range_texture

func update_tower_preview(new_pos, color):
	get_node(TOWER_PREVIEW_NODE_NAME).set_position(new_pos)
	if get_node(TOWER_PREVIEW_NODE_NAME + "/" + TOWER_NAME_WHEN_DRAGGED).modulate != Color(color):
		get_node(TOWER_PREVIEW_NODE_NAME + "/" + TOWER_NAME_WHEN_DRAGGED).modulate = Color(color)
		get_node((TOWER_PREVIEW_NODE_NAME + "/" + TOWER_RANGE_INDICATOR_NODE_NAME)).modulate = Color(color)

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
		play_play_sound()
	elif get_parent().current_wave == 0:
		get_parent().start_next_wave()
		play_play_sound()
	else:
		get_tree().paused = true
		play_pause_sound()

func play_play_sound():
	var sfx_file = load("res://assets/sound_effects/maximize_006.ogg")
	play_sound_file(sfx_file)

func play_pause_sound():
	var sfx_file = load("res://assets/sound_effects/minimize_006.ogg")
	play_sound_file(sfx_file)

func play_fast_forward_sound(level):
	var sfx_file
	if level == 1:
		sfx_file = load("res://assets/sound_effects/minimize_005.ogg")
	else:
		sfx_file = load("res://assets/sound_effects/maximize_005.ogg")
	play_sound_file(sfx_file)

func play_sound_file(file):
	ui_sound_effects.set_stream(file)
	ui_sound_effects.play()

func _on_fast_forward_button_pressed():
	if get_parent().construction_mode:
		get_parent().cancel_construction_mode()
	
	if Engine.get_time_scale() == 1.0:
		play_fast_forward_sound(2)
		Engine.set_time_scale(2.0)
	elif Engine.get_time_scale() == 2.0:
		play_fast_forward_sound(3)
		Engine.set_time_scale(5.0)
	else:
		play_fast_forward_sound(1)
		Engine.set_time_scale(1.0)

# TODO: these keybindings MUST work when game is paused!!!
func _input(event):
	if event.is_action_released("td_play_pause"):
		_on_play_pause_button_pressed()
	if (event.is_action_released("td_show_health_bars")):
		health_bars_visible = not health_bars_visible
	if (event.is_action_released( "td_show_range_indicators")):
		range_indicators_visible = not range_indicators_visible
	if (event.is_action_released("td_fast_forward")):
		_on_fast_forward_button_pressed()
