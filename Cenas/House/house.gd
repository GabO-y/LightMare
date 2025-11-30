extends Node2D

class_name House

@export var player: Player
@export var room_manager: RoomManager
@export var camera: Camera2D
@export var menu_manager: MenuManager
@export var initial_position: Marker2D

@export var die_menu: DieMenu
@export var finish_menu: FinishMenu
@export var inital_menu: InitialMenu
@export var tutorial_menu: TutorialMenu

@export var only_play: bool = false

var can_reset: bool = false

var follow: Node2D

var start_time: int

func _ready() -> void:
	
	Globals.house = self
	Globals.player = player
	
	print(player)
	
	room_manager.set_initial_room("SafeRoom")
	player.global_position = initial_position.global_position
	
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	
	die_menu.house = self
	
	player._die.connect(
		func():
			die_menu.set_active(true)
			die_menu.start_anim_1()
	)
	
	room_manager.boss_finished.connect(finish_menu.start)
	
	if room_manager.current_room.name == "SafeRoom":
		for door in room_manager.current_room.doors:
			door.open()
			
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	player.set_active(false)
	
	if only_play:
		inital_menu.set_active(false)
		tutorial_menu.set_active(false)
		player.set_active(true)
		start_time = Time.get_ticks_msec()
		
	if true:
		
		var room = "TutorialRoom"
		
		for door in room_manager.get_room("SafeRoom").doors:
			door.name = room
			break
			
		for door in room_manager.get_room(room).doors:
			door.name = "SafeRoom"
			break
		
		room_manager.match_doors("SafeRoom", room)
	
	await inital_menu.start_play
	
	player.set_active(true)
	start_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
		
	if camera.enabled:
		if is_instance_valid(follow):
			camera.global_position = follow.global_position
		else:
			camera.enabled = false

# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom

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
		
	die_menu.reset()
		
	reseted.emit()
	
func calc_game_time_sec():
	var time = Time.get_ticks_msec() - start_time
	return time / 1000
	
signal reseted
