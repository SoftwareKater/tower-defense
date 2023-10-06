extends Node2D

# name of the current map
var current_map = "Map1"
# the current map
var map_node: Node

##
## Construction
##

# whether we are currently in construction mode
var construction_mode = false
# tower can be build on the current_tile
var construction_valid = false
# the tile where a tower was just constructed
var constructed_tile
# the location where the tower should be constructed
var construction_location
# the type of tower that is constructed
var construction_type

##
## Wave
##

var current_wave = 0
var mobs_in_wave = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	map_node = get_node((current_map)) # Turn this into var based on selected map
	
	for i in get_tree().get_nodes_in_group("ShopButton"):
		i.connect("pressed", initiate_construction_mode.bind(i.get_name()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if construction_mode:
		update_tower_preview()

##
## Construction
##

func initiate_construction_mode(tower_type):
	if construction_mode:
		cancel_construction_mode()
	print(tower_type)
	# set construction type based on tower_type
	if tower_type == "MachineGunT1Button":
		construction_type = "machine_gun_t_1"
	elif tower_type == "MachineGunT2Button":
		construction_type = "machine_gun_t_2"
	elif tower_type == "MissileT1Button":
		construction_type = "missile_t_1"
	else:
		push_error("Cannot find tower type")
		return
		
	construction_mode = true
	get_node("UI").set_tower_preview(construction_type, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var tile_pos = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cell_source_id(0, current_tile) == -1:
		get_node("UI").update_tower_preview(tile_pos, "ad54ff3c")
		construction_valid = true
		construction_location = tile_pos
		constructed_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_pos, "b9082e98")
		construction_valid = false

# only receives the event if the signal is not consumed by the canvas/ui layer
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and construction_mode == true:
		cancel_construction_mode()
	if event.is_action_released("ui_accept") and construction_mode == true:
		verify_and_construct()

func cancel_construction_mode():
	construction_mode = false
	construction_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_construct():
	if construction_valid:
		# add cash test
		var new_tower_scene = "res://scenes/towers/" + construction_type + ".tscn"
		var new_tower = load(new_tower_scene).instantiate()
		new_tower.set_position(construction_location)
		new_tower.constructed = true
		new_tower.tower_type = construction_type
		map_node.get_node("TowerContainer").add_child(new_tower, true)
		# fill the tile with an invisible structure, to prevent construction of
		# another tower on top of it
		# TODO: this is not working
		map_node.get_node("TowerExclusion").set_cell(0, constructed_tile, 5)
		# deduct cash
		# update cash label


##
## Wave
##

func start_next_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout  ## padding between waves
	spawn_mobs(wave_data)
	
func retrieve_wave_data():
	var wave_data = [["blue_tank", 3], ["blue_tank", 2], ["blue_tank", 1], ["blue_tank", 1]]
	current_wave += 1
	mobs_in_wave = len(wave_data)
	return wave_data

func spawn_mobs(wave_data):
	for i in wave_data:
		var new_mob = load("res://scenes/mobs/" + i[0] + ".tscn").instantiate()
		map_node.get_node("Path").add_child(new_mob, true)
		await get_tree().create_timer(i[1]).timeout
