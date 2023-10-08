extends ColorRect

@onready var player_health_bar = get_node("HBoxContainer/HealthInfo/PlayerHealthBar")
@onready var player_money_label = get_node("HBoxContainer/MoneyInfo/MoneyLabel")
@onready var current_wave_label = get_node("HBoxContainer/WaveInfo/WaveCounter")
@onready var countdown_next_wave_label = get_node("HBoxContainer/NextWaveCountdown/Countdown")
@onready var remaining_mobs_label = get_node("HBoxContainer/WaveInfo/RemainingMobs")

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
		countdown_next_wave_label.set_modulate(Color(Constants.ERROR_TEXT_COLOR_HEX))
	else: 
		countdown_next_wave_label.set_modulate(Color(Constants.STD_TEXT_COLOR_HEX))
	countdown_next_wave_label.text = "Next Wave in: " + str(sec)

func show_insufficient_money():
	player_money_label.set_modulate(Color(Constants.ERROR_TEXT_COLOR_HEX))
	await get_tree().create_timer(0.3).timeout
	player_money_label.set_modulate(Color(Constants.STD_TEXT_COLOR_HEX))
