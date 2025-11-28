extends Node2D

class_name RoundManagar

var rounds: Array[Round]
var is_round_playing: bool = false
var round_playing: Round = null

var aux_times: int = 1
var quant_spawn: int = 1
var quant_ene: int = 1
var quant_horder: int = 1
var current_lv = 1

var count_ene_defaulted: int = 0

@export var room_manager: RoomManager

func get_random_round(size: int) -> Round:
	

	var quantity = quant_ene
	var time_spawn = 1.5
	var level = current_lv
	
	var spawns: Array[Spawn]

	for i in range(quant_spawn):
		
		var s = Globals.room_manager.current_room.spaweners.get(i)
		
		if s is Spawn:
			spawns.append(s)
			
	quant_spawn = spawns.size()
			
	var round = Round.new()
	round.manager = self
	
	var is_horder: bool = true
	
	while size > 0:
		var exe: Exe
		
		if is_horder:
			var ene_name = ["Ghost", "Zombie", "Skeleton"].pick_random()
			exe = create_horder(ene_name, quantity, time_spawn, current_lv, spawns)
			size -= 1
		else:
			exe = create_await(0.5)
			
		is_horder = !is_horder
		
		exe.round = round
		round.add_exe(exe)
	
	Globals.ene_to_default = quant_ene * quant_spawn * quant_horder
	return round

func setup_next_level():
	
	if aux_times % 2 == 0:
		quant_ene += 1
		quant_spawn += 1
	if aux_times % 3 == 0:
		quant_horder += 1
		
	if quant_ene >= 3:
		quant_ene = 3
		
	if quant_spawn >= 2:
		quant_spawn = 2
	
	if quant_horder >= 2:
		quant_ene = 2
		
	current_lv += 1
	aux_times += 1
	
	
	Globals.player.current_ene_defalut = 0
	
func start_random_round():

	var round = get_random_round(quant_horder)

	add_child(round)

	round.play()
	
	is_round_playing = true
	
	round.finished.connect(round_finished.emit)
	
	round_finished.connect(
		func():
			is_round_playing = false		
	)
	

func create_horder(ene_name: String, quantity: int, time_spawn: float, level: int, spawns: Array[Spawn]) -> Exe:
	var horder = Horder.new()

	horder.ene_name = ene_name
	horder.quantity = quantity
	horder.time_spawn = time_spawn
	horder.level = level
	horder.spawns = spawns
	
	return horder

func create_await(time: float) -> Exe:
	var aw = Await.new()
	aw.time = time
	return aw

func create_round(exes: Array[Exe]):
	var round = Round.new()
	round.exes = exes
	rounds.append(round)
	
func reset():
	
	aux_times = 1
	
	quant_spawn = 1
	quant_ene = 1
	quant_horder = 1
	
	current_lv = 1
	
	reset_rounds.emit()
		

signal round_finished

signal reset_rounds

class Round extends Node2D:
		
	var manager: RoundManagar
		
	var exes: Array[Exe]
	var _can_consume_exe: bool = true
	var _current_exe: Exe
	var _is_last_exe: bool = false
	
	func _ready() -> void:
		set_process(false)
		manager.reset_rounds.connect(queue_free)
		
	
	func add_exe(exe: Exe):
		exes.append(exe)
		
	func play():
		set_process(true)
		
	func _process(delta: float) -> void:
		
		if _can_consume_exe:
			consume_exe()
			_can_consume_exe = false
		elif _current_exe.is_finished:
			
			exes.erase(_current_exe)
			
			if is_finish():
				finished.emit()
				set_process(false)
				return
			
			_can_consume_exe = true
		else:
			_current_exe.play(delta)

	func _check_finish():
		if is_finish():
			finished.emit()
			set_process(false)

	func is_finish():
	
		if exes.size() > 0:
			return false
	
		if _current_exe is Horder:
			print(Globals.player.current_ene_defalut, "/", Globals.ene_to_default)
			if Globals.player.current_ene_defalut < Globals.ene_to_default:
				return false
					
		if _current_exe is Await:
			if _current_exe.time > 0.0:
				return false

		return true
		
	func consume_exe():
		
		if exes.size() <= 0:
			set_process(false)
			return
			
		if exes.size() == 1:
			_is_last_exe = true
		
		_current_exe = exes.get(0)
		exes.remove_at(0)
		
	func reset():
		for exe in exes:
			if is_instance_valid(exe):
				exe.is_finished = true
				exe.reset()
				exes.erase(exe)
				exe.queue_free()
		queue_free()
		
	signal finished
			
		
class Exe:
	
	var is_finished: bool = false
	var round: Round
	
	func play(delta: float):
		pass
		
	func reset():
		pass
	
class Horder extends Exe:
		
	var ene_name: String
	var quantity: int
	var time_spawn: float
	var level: int
	var spawns: Array[Spawn]
	var count: int = 0
	var is_first: bool = true
	
	var _timer: float = 0.0
	var _ene_spawned: Array[Enemy]
	
	func play(delta):

		if quantity <= 0:
			is_finished = true
		
		if is_finished: return
		
		if _timer >= time_spawn:
			
			for s in spawns:
				var ene = s.spawn(ene_name, level)
				
				_ene_spawned.append(ene)
				
				ene.enemy_die.connect(
					func(ene):
						Globals.player.current_ene_defalut += 1
						Globals.enemies_defalted += 1
						round._check_finish()
				)
				
				round.finished.connect(
					ene.queue_free
				)
				
				round.manager.reset_rounds.connect(
					func():
						if ene:
							ene.queue_free()
				)
				
			_timer = 0.0
			quantity -= 1
		
		_timer += delta
		
		
class Await extends Exe:
	var time: float
	var _timer: float = 0.0
	
	func play(delta):
		
		if _timer >= time:
			is_finished = true
		
		if is_finished:
			return
			
		_timer += delta
		
	
	
