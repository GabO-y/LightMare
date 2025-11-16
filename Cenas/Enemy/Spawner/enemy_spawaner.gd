extends Node2D

class_name Spawn

@export var type_enemie: PackedScene
@export var limit_spawn = 0
@export var time_to_spawn = 3.0
@export var enimies_level = 1
@export var timer: Timer
@export var spawn_area: Area2D

var room: Room
var is_active = false
var enemies_already_spawner = 0
var enemies: Array[Enemy] = []

var round: Round
	
func _ready() -> void:
	timer.wait_time = time_to_spawn
	
func get_random_point_in_area(area: Area2D) -> Vector2:
	var collision_shape = area.get_node("CollisionShape2D") as CollisionShape2D
	
	if not collision_shape or not collision_shape.shape:
		push_error("Area2D não tem CollisionShape2D ou shape definido!")
		return area.global_position
	
	if collision_shape.shape is CircleShape2D:
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		
		var angle = randf_range(0, TAU)
		var distance = sqrt(randf()) * radius
		
		# Calcula o ponto em coordenadas locais do CollisionShape2D
		var local_point = Vector2(cos(angle), sin(angle)) * distance
		
		# Converte para coordenadas globais CORRETAMENTE
		return collision_shape.to_global(local_point)
	else:
		push_error("O shape não é um CircleShape2D!")
		return area.global_position

func spawanEmenie() -> Enemy:
	
	if type_enemie == null:
		push_error("ENEMY TYPE IS NULL: ", get_path())
		get_tree().quit()
		return
	
	var point = get_random_point_in_area($Area2D)
	
	point = $Area2D.to_local(point)/2
		
	var ene = type_enemie.instantiate() as Enemy
	
	ene.global_position = point
	ene.position_target = point
	
	ene.enemy_die.connect(_free_enemy)
	ene.enemy_die.connect(room._check_clear_by_ene_die)
	ene.enemy_die.connect(room.manager.item_manager.try_drop)
	
	add_child(ene)
		
	ene.set_active(is_active)

	return ene
	
func set_enemie(ene: PackedScene):
	type_enemie = ene
	
func enable():
	set_active(true)

func disable():
	set_active(false)
	
	
func set_active(mode: bool):
	
	for enemy in enemies:
		enemy.set_active(mode)
		
	if mode:
		timer.start()
	else:
		timer.stop()
		
	set_process(mode)
	visible = mode
	
	is_active = mode
				
func is_clean() -> bool:	
	if enemies.size() > 0: return false
	if enemies_already_spawner < limit_spawn: return false
	
	return true
				
func _free_enemy(ene: Enemy):
	enemies.erase(ene)
	ene.die()

func _on_timer_to_spawn_a_enemy() -> void:
	
	if enemies_already_spawner < limit_spawn:
		enemies.append(spawanEmenie())
		enemies_already_spawner += 1
	else:
		timer.stop()
		
func spawn(ene_name: String, round: Round) -> Enemy:
	var ene = load("res://Cenas/Enemy/" + ene_name + "/" + ene_name + ".tscn").instantiate() as Enemy
		
	Globals.room_manager.current_room.call_deferred("add_child", ene)
	
	Globals.house.reseted.connect(
		func():
			if ene:
				enemies.erase(ene)
				ene.queue_free()
	)
			
	ene.global_position = get_random_circle_point() 
	
	ene.enemy_die.connect(_free_enemy)
	ene.enemy_die.connect(round._check_finish_round)
	ene.enemy_die.connect(room.manager.item_manager.try_drop)
	ene.enemy_die.connect(
		func(ene):
			print(Globals.enemies_defalted)
			Globals.enemies_defalted += 1
	)

	ene.set_active(true)
	
	enemies.append(ene)
		
	return ene
	
func get_random_circle_point() -> Vector2:
	
	var circle: CircleShape2D
	
	for child in spawn_area.get_children():
		if child is CollisionShape2D:
			circle = child.shape 
	
	var r_ = circle.radius * sqrt(randf())
	var t_ = randi_range(0, 360)
	
	
	return Vector2(r_ * cos(t_), r_ * sin(t_)) + global_position
