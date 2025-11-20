extends Node2D
class_name RoomManager

var rooms: Array[Room]

@export var roomsNode: Node2D
@export var item_manager: ItemManager
@export var key_manager: KeyManager
@export var round_manager: RoundManagar

var can_create_key: bool = true

# para posicionar as chaves geradas onde o ultimo inimigo morreu
var last_ene_pos: Vector2

var current_room: Room

func _ready() -> void:
		
	for room in roomsNode.get_children():
				
		if room is Room:
			
			room.add_to_group("rooms")
			room.desable()
			rooms.append(room)
			
			room.manager = self
			
			for door in room.doors:
				door = door as Door
				door.enter_door.connect(_change_room)

	for room in rooms:
		for door in room.doors:
			match_doors(room.name, door.name)

	round_manager.round_finished.connect(
		func():
			
			if not current_room.can_return and not Globals.is_reseting:
				current_room.finish = true
				
			_clear_effects()
	)

func get_doors(room: Room) -> Array[Door]:
	var doors: Array[Door]
	for door in room.doors:
		doors.append(door)
	return doors
	
func _change_room(goTo):
		
#	Para o caso do player mudar de sala, 
#   mas ainda haver items que não foram coletados
	item_manager.get_all_items(null)
	
	# Caso vc passe pela porta e não tenha tocado na chave
	item_manager.finish_get_key()
	
	current_room.desable()

	var room_name = current_room.name
	
	current_room = goTo
	current_room.enable()
	
	var door_target = current_room.get_door(room_name)

	Globals.player.body.global_position = door_target.area.global_position
	
	Globals.can_teleport = false
	
	Globals.current_level += 1
	
	if current_room is BossRoom:
		current_room.boss.setup()
	else:
		round_manager.make_ramdom_round(1, Globals.current_level)
		round_manager.play_round()  
	
	print("current room: ", current_room.finish)
	
	await get_tree().create_timer(0.2).timeout
	Globals.can_teleport = true
	
	changed_room.emit(current_room)

func find_room(room_name: String) -> Room:
		
	for room in rooms:
		if room.name.to_lower() == room_name.to_lower():
			return room
	print("Room: ", room_name, " not be found")
	return null

func match_doors(r_current: String, r_target: String):

	var door_current: Door
	var door_target: Door

	r_current = r_current.to_lower()
	r_target = r_target.to_lower()

	var d_current = r_target.to_lower()
	var d_target = r_current.to_lower()
	
	var find_r1 = false
	var find_r2 = false
	
	for room in rooms:
		
		var result: Door
		
		if room.name.to_lower() == r_current:
			find_r1 = true
			result = room.get_door(d_current)
			if result != null:
				door_current = result
				
		if room.name.to_lower() == r_target:
			find_r2 = true
			result = room.get_door(d_target)
			if result != null:
				door_target = result
			
	if not find_r1:
		print("room: ", r_current, ", nao encontrado")
		return
	if not find_r2:
		print("room: ", r_target, ", nao encontrado")
		return
	
	if door_current == null:
		print("porta: ", d_current, " nao encontrado, do quarto: ", r_current)
		return
	if door_target == null:
		print("porta: ", d_target, " nao encontado, do quarto: ", r_target)
		return
		
	door_current.goTo = door_target.get_parent().get_parent()
	door_target.goTo = door_current.get_parent().get_parent()
		
func enable_room(room_name: String):
	set_mode_room(room_name, true)
	
func desable_room(room_name: String):
	set_mode_room(room_name, false)

func set_mode_room(room_name: String, mode: bool):
	for room in rooms:
		if room.name == room_name:
			if mode:
				room.enable()
			else:
				room.desable()
			return
			
	print("room: ", room_name, " not found")
	return

func get_room(room_name: String):
	for room in rooms:
		if room.name == room_name:
			print("quarto: ", room_name, ", encontrado")
			return room
			
	print("room: ", room_name, ", não encontrado")
	
func teleport_to_room(room_name: String):
	var room = get_room(room_name)
	Globals.player.body.global_position = room.camera.global_position
	
func set_initial_room(room_name: String):
	
	if current_room:
		current_room.desable()
		
	var room = get_room(room_name)
	
	if !room: print("falha ao por quarto inicial")
	
	current_room = room
	room.enable()

func get_room_logic() -> Room:
	return current_room
	
func show_rounds():
	for room in rooms:
		if room.has_rounds():
			room.show_rounds()
			
func _clear_effects():
	key_manager.try_open_door()
	item_manager.make_items_chase_player()
	round_manager.is_playing_round = false

func reset():
	
	for room in rooms: 
		room.reset()
		
	current_room.desable()
	current_room = get_room("SafeRoom")
	current_room.enable()
	
	current_room.finish = true
	
signal changed_room(room: Room)
