extends Node

var current_room: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []
var is_get_animation = false
var center_pos: Vector2
var special_time_ghost_run = 2
var curren_menu: Control

var current_level:int = 0
var quantity_ene:  float = 1
var quantity_horder: float = 1
var quantity_spawns: float = 1

var enemies_defalted: int = 0
var conquited_coins: int = 0

var room_manager: RoomManager
var item_manager: ItemManager
var key_manager: KeyManager
var house: House

var only_use_key: bool = false

var ene_to_default: int = 0

var is_mute: bool = false

# mapa de qual nova diagonal ele deve ir dependendo de onde bate
var dir_possibles_crash_wall = {
		Vector2( 1,   1)  : {"right" : Vector2(-1,  1), "down" : Vector2( 1, -1)},
		Vector2( 1,  -1)  : {"right" : Vector2(-1, -1), "up"   : Vector2( 1,  1)},
		Vector2(-1,   1)  : {"left"  : Vector2( 1,  1), "down" : Vector2(-1, -1)},
		Vector2(-1,  -1)  : {"left"  : Vector2( 1, -1), "up"   : Vector2(-1,  1)}
	}

var layers = {
	"player" : 1 << 0,
	"enemy" : 1 << 1,
	"boss": 1 << 2,
	"wall_boss": 1 << 3,
	"current_wall": 1 << 4,
	"out_room_boss": 1 << 5,
	"ghost": 1 << 6,
	"no_collision_wall": 1 << 7,
	"armor": 1 << 8,
	# Para uns obstaculos nos quartos (toy_library)
	"utils_wall": 1 << 9
}

var ene_in_crash_attack: Array[Enemy]
var special_ghost_collision = 2

var already_center = 0

var is_reseting: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	
	if die:
		if Input.is_key_label_pressed(KEY_SPACE):
			get_tree().reload_current_scene()
			get_tree().paused = false
			die = false
		
func desable_room():
	current_room.desable()
	
func enable_room():
	current_room.enable()
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false

func is_clean_room():
	return current_room.is_clean()

	
func update_room_light():
	current_room._update_doors_light()
	
#func change_room():
	#current_room._update_doors_light()
	#current_room.update_layers()
	#if current_room.finish: return

func time(time: float):
	return get_tree().create_timer(time).timeout
	
func _on_goint_to_center():
	already_center += 1
	if already_center >= 8:
		emerge_boss.emit()
		already_center = 0

func player_pos(): 
	if !player:
		print("PLAYER NULL")
		return Vector2(0, 0)
	return player.body.global_position


func get_special_time_ghost_run():
	special_time_ghost_run += 0.5
	return special_time_ghost_run

func dir_to(current: Vector2, target: Vector2):
	return current.direction_to(target)
	
func setup_next_round():
	
	current_level += 1
	
	quantity_ene += 0.5
	quantity_horder += 0.5
	quantity_spawns += 0.5
		
	if quantity_ene > 2.0:
		quantity_ene = 2.0
	if quantity_horder > 2.0:
		quantity_horder = 2.0
	if quantity_spawns > 2.0:
		quantity_spawns = 2.0
		
	player.current_ene_defalut = 0
	ene_to_default = int(floor(Globals.quantity_ene) * floor(Globals.quantity_horder) * floor(Globals.quantity_spawns)) 

func debug_area(area: Area2D):
	print(area.get_path())
	print("\tlayer: ", area.collision_layer)
	print("\tmask: ", area.collision_mask)

signal goint_to_center

signal emerge_boss
