extends Node2D

class_name Round

@export var room: Room

var type_exe: String 

var instruction: Array[Dictionary] = []
var spawners: Array[Spawn]

var await_timer: float = 0.0
var await_duration: float
var is_awaiting: bool = false

var ene_name: String
var delay: float 
var delay_timer: float = 0.0
var quantity: int
var is_spawn_ene: bool = false
var count_ene: int = 0
var level_ene: int = 0

var last_ene: Enemy

var has_instructions: bool = true

var is_playing: bool = false

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
				
	match type_exe:
		"await":			
			if await_timer >= await_duration:
				
				type_exe = ""
				
				await_timer = 0.0
				is_awaiting = false
				exe()
				return
			
			await_timer += delta
		"horder":
		
			if count_ene >= quantity:
				type_exe = ""
				is_spawn_ene = false
				return
			
			if delay_timer >= delay:
				for s in spawners:
					
					print("spawn")
					var ene = s.spawn(ene_name, self, level_ene)
					print("spawn fim")
						
				count_ene += 1
				delay_timer = 0.0
				
			delay_timer += delta
			
		_: 
			exe()

func set_room(room: Room):
	self.room = room
	for spawn in room.spaweners:
		spawners.append(spawn)

func _check_finish_round(ene: Enemy):
	
	if instruction.size() > 0: return
	
	for spawn in spawners:
		if not spawn.is_clean():
			return
			
	finish_round()
		

func start():
	set_process(true)
	
	var total_quanty: int = 0
	
	for i in instruction:
		i = i as Dictionary
		if i.has("horder"):
			total_quanty += i["quantity"]
			
	for s in spawners:
		s.limit_spawn = total_quanty
	
	exe()
	 
func exe():
		
	if instruction.size() <= 0 or not has_instructions:
		type_exe = ""
		has_instructions = false
		return
		
		
	is_playing = true
					
	var inst = instruction.get(0)
	instruction.remove_at(0)
	
	type_exe = inst["type"]
		
	match type_exe:
		"await":
			is_awaiting = true
			await_duration = inst["duration"]
			await_timer = 0.0
		"horder":
			is_spawn_ene = true
			ene_name = inst["ene_name"] 
			delay = inst["delay"]
			quantity = inst["quantity"]
			level_ene = inst["level"]
			count_ene = 0
				

func add_await(time: float):
	instruction.append({
		"type": "await",
		"duration": time
	})
	
func reset():
	for spawn in spawners:
		spawn.reset()
	instruction.clear()
	queue_free()
	
func add_horder(ene_name: String, quantity: int, level: int ,delay: float = 0.5):
	instruction.append({
		"type": "horder",
		"ene_name": ene_name,
		"quantity": quantity,
		"delay": delay,
		"level": level
	})
	
func show_exe():
	for i in instruction:
		for key in i.keys():
			if key == "type":
				print("\t", i[key], ": ")
			else:
				print("\t\t", key, ": ", i[key])
				
				
func finish_round():
	room.rounds.erase(self)
	
	await get_tree().process_frame

	is_playing = false
	finished.emit()
	
	queue_free()


signal finished
