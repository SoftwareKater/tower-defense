extends PathFollow2D

var speed = 150
var hit_points = 150

@onready var health_bar = get_node("HealthBar")
@onready var ui_node = get_node("/root/SceneHandler/GameScene/UI")

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
	hit_points -= damage
	if hit_points <= 0:
		on_destroy()
	health_bar.value = hit_points
		
func on_destroy():
	self.queue_free()
