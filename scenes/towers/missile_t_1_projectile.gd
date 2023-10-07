extends CharacterBody2D

var speed = 500
var damage
var target
var start_position

func _ready():
	self.set_position(start_position)

func _physics_process(delta):
	homing(delta)

func _on_area_2d_body_entered(body):
	if "Tank" in body.name:
		explode()
		body.get_parent().on_hit(GameData.tower_data["missile_t_1"]["damage"])
		queue_free()

func explode():
	# run animation
	print("BOOM")

func homing(delta):
	if !target:
		queue_free()
		return
	var target_pos = target.get_position()
	velocity = global_position.direction_to(target_pos) * speed
	look_at(target_pos)
	move_and_slide()
