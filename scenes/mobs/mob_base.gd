extends PathFollow2D

var mob_type

signal reached_end(damage)
signal destroyed(reward_for_destruction)

var damage_when_reaching_end
var speed
var hit_points
var reward_for_destruction

@onready var health_bar = get_node("HealthBar")
@onready var ui_node = get_node("/root/SceneHandler/GameScene/UI")

@onready var impact_area = get_node("ImpactPosition")
var projectile_impact = preload("res://scenes/support/projectile_impact_animation.tscn")

var destruction = preload("res://scenes/support/tank_destruction_animation.tscn")

func _ready():
	if not mob_type:
		push_error("Mob was instantiated without mob_type. Destroying mob!")
		queue_free()
		return
	damage_when_reaching_end = GameData.mob_data[mob_type]["damage"]
	speed = GameData.mob_data[mob_type]["speed"]
	hit_points = GameData.mob_data[mob_type]["hp"]
	reward_for_destruction = GameData.mob_data[mob_type]["reward"]
	health_bar.max_value = hit_points
	health_bar.value = hit_points
	health_bar.set_as_top_level(true)

func _process(delta):	
	health_bar.visible = ui_node.health_bars_visible

func _physics_process(delta):
	if get_progress_ratio() == 1.0:
		emit_signal("reached_end", damage_when_reaching_end)
		queue_free()
	move(delta)
	
func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.set_position(self.position - Vector2(32, 32))

func on_hit(damage):
	impact_animation()
	hit_points -= damage
	if hit_points <= 0:
		on_destroy()
		return
	health_bar.value = hit_points

func impact_animation():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.set_position(impact_location)
	impact_area.add_child(new_impact)

func on_destroy():
	var last_pos = get_node("TankCharacterBody").get_position()
	get_node("TankCharacterBody").queue_free()
	destroy_animation(last_pos)
	await get_tree().create_timer(0.2).timeout
	emit_signal("destroyed", reward_for_destruction)
	self.queue_free()

func destroy_animation(pos):
	var new_destruction_animation = destruction.instantiate()
	new_destruction_animation.set_position(pos)
	self.add_child(new_destruction_animation)
	
