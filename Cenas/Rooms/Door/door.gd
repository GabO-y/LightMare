extends Node2D

class_name Door

@export var my_room: Room
@export var area: Area2D;
var goTo: Room #Room que ele deve ir

@export var is_locked: bool			
@export var light: PointLight2D 
@export var open_door_sprite: TileMapLayer
@export var unlock_audio: AudioStreamPlayer

func _ready():
	area.body_entered.connect(_player_enter)

func _player_enter(body):
	
	var player = body.get_parent() as Player
	if player == null: return

	if !Globals.can_teleport:
		return
		
	if is_locked:
		return
				
	enter_door.emit(goTo)
	
func turn_light(turn: bool):
	light.visible = turn
	if open_door_sprite != null:
		open_door_sprite.visible = turn
		
func enable():
	set_active(true)
	
func desable():
	set_active(false)
		
func set_active(mode: bool):
	visible = mode
	area.set_deferred("monitorable", mode)
	area.set_deferred("monitoring", mode)
	turn_light(mode)
	
func all_lock():

	is_locked = true
	
	for door in goTo.doors:
		print("\t", door.name)
		if door.name == my_room.name:
			door.is_locked = true
			return
			
func open():
	is_locked = false
	set_active(true)
		
	for door in goTo.doors:
		if door.name == my_room.name:
			door.is_locked = false
			break
		
signal enter_door(goTo)
