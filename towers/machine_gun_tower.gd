extends StaticBody2D

var bullet = preload("res://towers/machine_gun_bullet.tscn")
var damage = 1
var invaders_in_range = []
var current_target = null
var fire_rate = 0.2
var last_fire = null
var target_aquisition_strategy = "FIRST_IN_SIGHT" # NEAREST_TO_END

func _ready():
	last_fire = Time.get_unix_time_from_system()

func _process(delta):
	if current_target:
		if Time.get_unix_time_from_system() > last_fire + fire_rate:
			__fire_bullet()
			last_fire = Time.get_unix_time_from_system()
'''
	Creates a new bullet instance
'''
func __fire_bullet():
	var bullet_to_be_fired = bullet.instantiate()
	bullet_to_be_fired.damage = damage
	get_node("BulletsFiredContainer").add_child(bullet_to_be_fired)
	bullet_to_be_fired.global_position = $TowerGunMuzzle.global_position

func _on_tower_range_body_entered(body):
	# Update the bodies in tower range, only take invaders into account
	if "Invader" in body.name:
		invaders_in_range.append(body)
	# Aquire a target from all bodies in range (just pick the first)
	if len(invaders_in_range) > 0:
		__acquire_target()
	else:
		current_target = null

func _on_tower_range_body_exited(body):
	# Update the bodies in tower range
	if "Invader" in body.name:
		invaders_in_range.erase(body)
	# Aquire a new target if the body leaving the range was
	# currently the target (just pick the first again)
	if len(invaders_in_range) > 0 and not current_target in invaders_in_range:
		__acquire_target()
	else:
		current_target = null

func __acquire_target():
	if target_aquisition_strategy == "FIRST_IN_SIGHT":
		current_target = invaders_in_range[0].get_parent()
#	if target_aquisition_strategy == "NEAREST_TO_END":
#		var max_progress = invaders_in_range.map(func(invader): invader.get_parent().get_progress_ratio()).max()
#		current_target = invaders_in_range.find(func(invader): invader.get_parent().get_progress_ratio() == max_progress).get_parent()
#	__print_target_aquired()

func __print_target_aquired():
	print("Aquiering Target")
	print(invaders_in_range)
	print(current_target)
	print()
