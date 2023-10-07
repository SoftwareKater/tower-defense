extends Node2D

var possible_targets = []
var target
var target_acquisition_mode = "MAX_PROGRESS" # "FIRST"
# whether the tower was already built
var constructed = false
var tower_type
var ready_to_fire = true
var animation_category

func _ready():
	if constructed:
		var collision_shape_radius = 0.5 * GameData.tower_data[tower_type]["range"]
		self.get_node("RangeArea/CollisionShape2D").get_shape().radius = collision_shape_radius

func _physics_process(delta):
	if possible_targets.size() != 0 and constructed:
		acquire_target()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if ready_to_fire:
			fire()
	else:
		target = null

##
## Target Acquisition
##

func acquire_target():
	if target_acquisition_mode == "MAX_PROGRESS":
		var target_progress_array = []
		for i in possible_targets:
			target_progress_array.append(i.get_progress())
		var max_progress = target_progress_array.max()
		var target_index = target_progress_array.find(max_progress)
		target = possible_targets[target_index]
	elif target_acquisition_mode == "FIRST":
		target = possible_targets[0]

func _on_range_area_body_entered(body):
	if not "Projectile" in body.get_name():
		possible_targets.append(body.get_parent())

func _on_range_area_body_exited(body):
	possible_targets.erase(body.get_parent())

##
## turn and fire
##

func turn():
	get_node("HeadSprite").look_at(target.position)

func fire():
	ready_to_fire = false
	if animation_category == "projectile":
		fire_projectile()
	elif animation_category == "missile":
		fire_missile()
	else:
		push_error("Unknown animation category. Aborting fire.")
	await get_tree().create_timer(GameData.tower_data[tower_type]["rate_of_fire"]).timeout
	ready_to_fire = true

func fire_projectile():
	get_node("AnimationPlayer").play("fire")
	target.on_hit(GameData.tower_data[tower_type]["damage"])
	
func fire_missile():
	get_node("AnimationPlayer").play("fire")
	var missile_projectile = load("res://scenes/towers/missile_t_1_projectile.tscn").instantiate()
	missile_projectile.target = target
	missile_projectile.start_position = get_node("HeadSprite/Missile1Sprite").get_position()
	self.get_node("ProjectileContainer").add_child(missile_projectile, true)
	await get_tree().create_timer(GameData.tower_data[tower_type]["reload_time"]).timeout
	get_node("AnimationPlayer").play("reload")
