extends Node2D

class_name KeyManager

@export var room_manager: RoomManager
@export var item_manager: ItemManager

# A cada troca de sala, ele verifica se há portas que podem ser abertas,
# caso haja, ele guarda nessa variavel
var current_door_can_open: Array[Door]

# Quando uma chave é criada, ela não é automaticamente lançada,
# quem lida com isso, é o item_manager, ent, essa variavel 
# vai guardar se tem uma chave pro item manager criar

var has_key: bool = false
var key: Key

func _ready() -> void:
	item_manager = room_manager.item_manager
	
func find_doors(room: Room):
	
	var doors: Array[Door]
	
	for door in room.doors:
		
		if door.goTo is BossRoom:
			if door.goTo.finish:
				continue
		
		if door.is_locked:
			doors.append(door)
	
#	Sorteia a porta que vai abrir
	var drawn_door = doors.pick_random() as Door
	
	if !drawn_door: return
	
#	Pega o quarto que a porta leva
	var room_target = drawn_door.goTo as Room
#	Variavel que vai pegar a porta correspondente ao quarto atual
	var door_target: Door
			
#   Com o quarto que a nossa porta sortada abre,
#   procuramos a porta correspondente
	for door in room_target.doors:
		if door.name == room_manager.current_room.name:
			door_target = door
			break
			
	if !door_target:
		return null
		
	return {
		"door_current": drawn_door,
		"door_target": door_target
	}
		
func create_key_by_door(door: Door):
	var key = load("res://Cenas/Keys/Key.tscn").instantiate() as Key
	key.door1 = door
	return key

func create_key(room: Room) -> Key:
		
	var doors = find_doors(room)
		
	if !doors: return null
	
	var key: Key = load("res://Cenas/Keys/Key.tscn").instantiate() 

	key.door1 = doors["door_current"]
	key.door2 = doors["door_target"]
	
	return key
	
func try_open_door():
	
	var available_doors: Array[Door] = []
	var retured_doors: Array[Door]
	var boss_doors: Array[Door]
		
	for door in room_manager.current_room.doors:
		
		var goTo = door.goTo

		if (not goTo.can_return and goTo.finish):
			continue
									
		if goTo.can_return:
			retured_doors.append(door)
			continue
			
		if goTo is BossRoom:
			boss_doors.append(door)
			continue
			
		available_doors.append(door)
							
	if not available_doors.is_empty():
		open_random_door(available_doors)
	elif not boss_doors.is_empty():
		open_random_door(boss_doors)
	else:
		open_random_door(retured_doors)
		
func open_random_door(doors: Array[Door]):
	
	
	if doors.is_empty(): return
	
	var door = doors.pick_random() as Door
		
	if door.is_locked:
		setup_key(create_key_by_door(door))
		return
		
	door.open()
	
func try_open_normal_room(doors: Array[Door]):
	pass
			
func setup_key(key: Key) -> Item:
		
	if !key: return
	
	call_deferred("add_child", key)
	
	key.collected.connect(item_manager._collect_item)
	
	key.type = item_manager.item_type.KEY
	
	if room_manager.last_ene_pos == Vector2.ZERO:
		key.global_position = key.door1.area.global_position
	else:
		key.global_position = room_manager.last_ene_pos

	key.manager = item_manager

	key.start_chase_player()
	
	item_manager.key_in_scene = key
	item_manager.items_node.add_child(key)
	
	return key
	
		
	
	
		
