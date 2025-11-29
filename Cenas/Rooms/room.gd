extends Node2D

class_name Room

@export var is_clear: bool = false
@export var finish = false
@export var spaweners: Array[Spawn]
@export var spread: bool = false
@export var doors: Array[Door]
@export var camera: Camera2D
@export var layer_node: Node2D
@export var manager: RoomManager
@export var door_node: Node2D

@export var is_camera_chase_mode: bool = false
@export var can_return: bool = false

var is_camera_chase: bool = true
var last_dir: Vector2 = Vector2.ZERO

var layers: Array[TileMapLayer]

var spread_one:bool = false
var total_enemies: int = 0
var already_drop_key: bool = false

func _ready() -> void:
	
	for child in get_children():
		
		if child is Camera2D:
			camera = child
		
		if child.name == "Spawners":
			for spawn in child.get_children():
				if spawn is Spawn:
					spaweners.append(spawn)
					spawn.room = self
					
		if child.name == "Doors":
			for door in child.get_children():
				if door is Door:
					doors.append(door)
					door.my_room = self
					
		if child.name == "Layers":
			for layer in child.get_children():
				if layer is TileMapLayer:
					layers.append(layer)

	

func _process(delta: float) -> void:
	if is_camera_chase_mode:
		camara_chase(delta)
		
func camara_chase(delta):
	if is_camera_chase:
		var y = (Globals.player_pos().y - camera.global_position.y) / 10
		camera.global_position.y += y
		last_dir = Globals.player.dir
	else:
		last_dir.y = move_toward(last_dir.y, 0, delta)	
		camera.global_position.y += last_dir.y
					
func calculate_total_enemies() -> int:	
	total_enemies = 0

	for spa in spaweners:
		total_enemies += spa.enemies.size()
		
	return total_enemies
	
func desable():
	set_active(false)
			
func enable():
	set_active(true)

func set_active(mode: bool):
	visible = mode
		
	if camera: camera.enabled = mode
	
	spread = mode
	
	set_process(mode)
	set_physics_process(mode)

	for door in doors:
		if door is Door:
			door.set_active(mode)
			
	for spawn in spaweners:
		if spawn is Spawn:
			spawn.set_active(mode)

	for layer in layers:

		layer.collision_enabled = mode
		layer.navigation_enabled = mode
		
		layer.set_process(mode)
		layer.set_physics_process(mode)
		
		var lar = Globals.layers["current_wall"] if mode else 0
				
		layer.tile_set.set_physics_layer_collision_layer(0, lar)
		layer.tile_set.set_physics_layer_collision_mask(0, lar)
		
	if mode:
		_update_doors()
			
func _update_doors():
	for door in doors:
		door.set_active(!door.is_locked and finish)

# Para todos os efeitos que devem acontecer quando um quarto é finalizado
func _clear_effects():
	is_clear = true
	finish = true

func get_door(door_name: String) -> Door:
	for door in doors:
		if door is Door and door.name.to_lower() == door_name.to_lower():
			return door
	return null

func open_door(door_name: String):
	for door in doors:
		if door.name == door_name:
			door.open()

func lock_all_doors():
	for door in doors:
		door.set_active(false)
	
#func is_round_playing():
	#
	#if !current_round: return false
	#
	#return current_round.is_playing
	#
#func add_round(round: Round):
	#rounds.append(round)
	#round.finished.connect(_clear_effects)
#
#func has_rounds():
	#for i in rounds:
		#return true
	#return false
	#
#func start_round():
	#
	#if not has_rounds(): return
		#
	#for r in rounds:
		#if is_instance_valid(r):
			#r.start()
			#current_round = r
		#else:
			#rounds.erase(r)
			#continue
		#return
#
#func show_rounds():
	#print(name, ":")
	#for r in rounds:
		#r.show_exe()
		#print("----------")
	
func reset():
	finish = false
	already_drop_key = false
	is_clear = false
	
	for spawn in spaweners:		
		spawn.set_active(false)
		
	for door in doors:
		door.is_locked = true
		door.set_active(false)
		
func get_random_spawn():
	return spaweners.pick_random()

func get_random_spawns(quant: int):
	
	var original_quant = quant
	
	if quant <= 0:
		return 
		
	if quant >= spaweners.size():
		return spaweners
	
	var spawns: Array[Spawn] = []
	
	var error = false
	
	while quant > 0:
		
		if abs(quant) > 100:
			error = true
			break
		
		var spawn = spaweners.pick_random()
		
		if spawn in spawns:
			quant += 1
			continue
			
		spawns.append(spawn)
		quant -= 1
		
	if error:
		
		spawns.clear()
		
		for i in range(original_quant - 1):
			
			var s = spaweners.get(i)
			
			if  not s is Spawn:
				print("deu nao")
				get_tree().quit()
				
			spawns.append(spaweners.get(i))
		
	return spawns

# fazendo a parte de items, quando sala limpa, item segue player
signal clear
 
