extends PathFollow2D

var speed = 150
var hit_points = 150

@onready var health_bar = get_node("HealthBar")
@onready var ui_node = get_node("/root/SceneHandler/GameScene/UI")

@onready var impact_area = get_node("ImpactPosition")
var projectile_impact = preload("res://scenes/support/projectile_impact_animation.tscn")

func _ready():
	health_bar.max_value = hit_points
	health_bar.value = hit_points
	health_bar.set_as_top_level(true)

func _process(delte):	
	health_bar.visible = ui_node.health_bars_visible

func _physics_process(delta):
	move(delta)
	
func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.set_position(self.position - Vector2(32, 32))

func on_hit(damage):
	impact()
	hit_points -= damage
	if hit_points <= 0:
		on_destroy()
	health_bar.value = hit_points

func impact():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.set_position(impact_location)
	impact_area.add_child(new_impact)

func on_destroy():
	get_node("TankCharacterBody").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.queue_free()

	
	
