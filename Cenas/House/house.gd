extends Node2D

class_name House

@export var player: Player
@export var room_manager: RoomManager
@export var camera: Camera2D
@export var menu_manager: MenuManager
@export var initial_position: Marker2D
@export var die_menu: DieMenu

var can_reset: bool = false

var follow: Node2D

func _ready() -> void:
	
	room_manager.set_initial_room("SafeRoom")
	player.global_position = initial_position.global_position
	
	Globals.house = self
	Globals.player = player
	
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	
	die_menu.house = self
	
	player._die.connect(die_menu.start_anim_1)
	
	room_manager.changed_room.connect(active_menu)
	
	if room_manager.current_room.name == "SafeRoom":
		for door in room_manager.current_room.doors:
			door.open()
			
		process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
		
	if camera.enabled:
		if is_instance_valid(follow):
			camera.global_position = follow.global_position
		else:
			camera.enabled = false

# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom
func active_menu(room: Room):
	
	var is_safe_room = room.name == "SafeRoom"
	
	$MenuManager/Menus/ChestMenu.set_process(is_safe_room)
	$MenuManager/ChestMenuInteratives.visible = is_safe_room

func set_camare_in(thing: Node2D, zoom: Vector2):
	camera.enabled = true
	room_manager.current_room.camera.enabled = false
	camera.zoom = zoom
	follow = thing
	
func desable_camera():
	camera.enabled = false
	room_manager.current_room.camera.enabled = true
		
		
func reset():
	
	player.reset()
	
	menu_manager.reset()
	
	room_manager.reset()
	
	room_manager.round_manager.reset()
	
	room_manager.item_manager.reset()

	player.global_position = initial_position.global_position
	
	for door in room_manager.current_room.doors:
		door.open()
		
	get_tree().paused = false
	
	Globals.conquited_coins = 0
	Globals.enemies_defalted = 0
	
	die_menu.reset()
	
	active_menu(room_manager.current_room)
	
	reseted.emit()
	
signal reseted
