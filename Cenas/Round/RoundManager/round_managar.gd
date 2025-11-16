extends Node2D

class_name RoundManagar

@export var room_managar: RoomManager

var round_queue: Array[Round]
var expecific_round: Dictionary

var is_playing_round: bool = false
var round_playing: Round

var expected_quantity: int = 3

func _ready() -> void:	
	#room_managar.changed_room.connect(_check_round_room)
	
	# type, ene_name, quantity, time_to_spawn
	
	#add_round(create_round(
		#[
			#["horder", "Zombie", "1", "2"],
			#["await", "2"],
			#["horder", "Ghost", "3", "0.1"]
		#]
	#))
	#
	
	
	pass
		
# toda vez que é trocado de sala, ele verifica
# se naquela sala tem um round agendado, se sim
# ele toca o round
#func _check_round_room(room: Room):
	#if room.has_rounds():
		#room.start_round()
		
# ao final de cada instrução, é necessario uma virgula
#func add_round(room_name: String, instrucs: String):
	#
	#var regex = RegEx.new()
	#regex.compile(r"(.*),+")
	#
	#var result = regex.search_all(instrucs)
	#
	#var seq_instruc: Array[String]
	#
	#for matches in result:
		#seq_instruc.append(matches.strings[1])
		#
	#regex.compile(r"([a-z]*)\s*\{([^}]*)\}")
		#
	#var round = load("res://Cenas/Round/Round.tscn").instantiate() as Round
	#
	#for inst in seq_instruc:
		#
		#result = regex.search(inst)
		#
		#var type: String = result.get_string(1)	
		#
		#var content: Array[String] = []
#
		#if result.get_string(2).contains(","):
			#for s in result.get_string(2).split(","):
				#s.replace(" ", "")
				#content.append(s)
		#else:
			#var s = result.get_string(2).replace(" ", "")
			#content.append(s)
#
		#match type:
			#"horder":
#
				#var ene_name: String = content[0]
				#var quantity: int = content[1] as int
				#var delay: float = content[2] as float
				#
				##print("horder:")
				##print("\t", ene_name)
				##print("\t", quantity)
				##print("\t", delay)
				#
				#
				#round.add_horder(
					#ene_name, quantity, delay
				#)
				#
			#"await":
				#var time: float = content[0] as float
				#
				##print("await:")
				##print("\t", time)
				#
				#round.await_time(time)
				#
	#var room = room_managar.find_room(room_name)
	#
	#round.set_room(room)
		#
	
func add_especific_round(room_name: String, round: Round):
	expecific_round[room_name] = round
	
func create_round(instruc: Array):
	
	var round = Round.new()
	
	for args in instruc: 
	
		match args.get(0):
			"horder":
				
				var ene_name: String = args.get(1)
				var quantity: int = int(args.get(2))
				var time_spawn: float = float(args.get(3))
				
				round.add_horder(ene_name, quantity, time_spawn)
				
			"await":
				var time: float = float(args.get(1))				
				round.add_await(time)
				
	return round

func add_round(round: Round):
	round_queue.append(round)
	
func play_round():
	
	if is_playing_round: return
	
	if not has_rounds():
		round_finished.emit()
		print("round_finished emitido")
		return
	
	is_playing_round = true
	room_managar.current_room.lock_all_doors()
	
	var round = round_queue.get(0) as Round
	
	call_deferred("add_child", round)
	
	await get_tree().process_frame
	
	round.finished.connect(
		func():
			is_playing_round = false
			round_finished.emit()
	)
	
	round.set_room(room_managar.current_room)
	round.start()
	
	round_playing = round
	
	round_queue.erase(round)

func has_rounds() -> bool:
	return round_queue.size() > 0
	
func make_ramdom_round(size: int):
	
	var type = "horder"
	var round: Round = Round.new()
	
	while size > 0:
		
		match type:
			"horder": 
				
				var ene_name = ["Zombie", "Ghost"].pick_random()
				ene_name = "Zombie"
				var quantity = randi_range(int(expected_quantity * 0.5), expected_quantity)
				var time_spawn = randf_range(0.5, 2.0)
				round.add_horder(ene_name, quantity, time_spawn)
				size -= 1
				
			"await": 
				var time = randf_range(3.0, 5.0)
				round.add_await(time)
		
		type = "horder" if type == "await" else "await"
		
	add_round(round)
		
func reset():
	is_playing_round = false
	round_queue.clear()
	expecific_round.clear()
		
signal round_finished
