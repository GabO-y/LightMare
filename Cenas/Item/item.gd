extends Node2D

class_name Item

@export var sprite: Sprite2D
@export var area: Area2D
@export var manager: ItemManager

@export var audio: AudioStreamPlayer


var dist = 1
var type

var is_move = false
# "chase_player", "drop_down"
var type_move = ""
var curve: MyCurve

func _ready() -> void:
	
	area.collision_mask = Globals.layers["player"]
	area.body_entered.connect(_on_player_body_entered)
	
	curve.progress_finish.connect(
		func():
			is_move = false
	)
		
func _process(delta: float) -> void:
	
	if is_move:
		match type_move:
			"curve_move":
				curve_move()
			"chase_player":
				chase_player()
			"drop_down":
				drop_down()
				
				
func curve_move():
	global_position = curve.get_point_by_progress()
	
func start_drop_down(item_curve: MyCurve):
		
	is_move = true
	type_move = "drop_down"
		
	curve = item_curve
	curve.progress = 0.0
	
	#curve.progress_finish.connect(
		#func():
			#is_move = false
			#global_position = curve.get_point(1)
	#)	

func drop_down():
	global_position = curve.get_point_by_progress()

# Pega um ponto da curva e atualiza para a nova pos do player
func chase_player():
	var p = curve.get_point_by_progress()
	global_position = p
	curve.set_p2(Globals.player_pos())
	
func set_go_to(pos: Vector2):
	var p1 = global_position
	p1.y += randi_range(-10, -20)
	
	curve = MyCurve.new(global_position, p1, pos)
	
	type_move = "curve_move"
	is_move = true
	
	var key = self as Key
	if key:
		
		key.is_going_to_door = true
		Globals.house.set_camare_in(key, Vector2(3.5, 3.5))
				
		curve.progress_finish.connect(
			func():
						
				key.is_going_to_door = false
				is_move = false
				key.use_when_arrieve.emit()
				
		)
	
# Gera a curva que o item vai seguir ate o player
func start_chase_player():
	
	is_move = true
	type_move = "chase_player"
	
	var p0 = global_position
	var p1 = p0
	var p2 = Globals.player_pos()
	
	var dir: Vector2 = p0.direction_to(p2) * 80
	
	p1 -= dir 
	
	dir.x = [-1,1].pick_random()
	dir.y = [-1,1].pick_random()
	
	dir *= 80
		
	p1 -= dir
	
	curve = MyCurve.new(p0, p1, p2)

func _on_player_body_entered(body: Node2D) -> void:
		
	var player = body.get_parent() as Player
	if player == null: return
	
	if audio:
		audio.play()
		
	collected.emit(self)
			
signal collected(item: Item)
