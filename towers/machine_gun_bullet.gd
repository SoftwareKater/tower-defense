extends CharacterBody2D

var speed = 500
var damage

func _physics_process(delta):
	var tower = get_parent().get_parent()
	var tower_hit_box = tower.get_child(0)
	var tower_range_box = tower.get_child(4).get_child(0)
	# if bullet is in tower hit box, then let it fly, else destroy it!
	velocity = tower_hit_box.get_position().normalized() * (-1) * speed
	move_and_slide()

func _on_area_2d_body_entered(body):
	if "Invader" in body.name:
		body.health -= damage
		queue_free()

#func __homeing_missle():
#	var pathSpawnerNode = get_tree().get_root().get_node("Main/PathSpawner")
#
#	for i in pathSpawnerNode.get_child_count():
#		if pathSpawnerNode.get_child(i).name == path_name:
#			target = pathSpawnerNode.get_child(i).get_child(0).get_child(0).global_position
#	if !target:
#		queue_free()
#		return
#	velocity = global_position.direction_to(target) * speed
#	look_at(target)
#	move_and_slide()
