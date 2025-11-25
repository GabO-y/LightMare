extends Character

class_name Enemy

var damage_att: Attribute = Attribute.new()
var speed_att: Attribute = Attribute.new()
var heath_att: Attribute = Attribute.new()

@export var speed: float = 0.0
@export var heath: float = 0.0
@export var damage: float = 0.0

var atributes: Array[Attribute]

@export var body: CharacterBody2D #Corpo do inimigo
@export var anim: AnimatedSprite2D

@export var bar: ProgressBar #Barra de progresso

var spawn: Spawn

var is_stop = false

var player: Player #Proprio jogador

var position_target #Para onde ele deve andar
var is_attacking = false #para verificar se esta atacando o player para ter que ficar parado
var is_active: bool = false
var knockback_force: float = 500.0
var is_dead: bool = false
var last_dir: Vector2


func _ready() -> void:
	
	player = Globals.player
	
	atributes.append_array([
		damage_att, speed_att, heath_att
	])
		
	for i in body.get_children():
		if i is ProgressBar:
			bar = i

	if bar != null:
		bar.max_value = heath
		bar.value = heath
		
func _process(_delta: float) -> void:
	update_bar()
	
func update_bar():
	if bar == null:
		return
	bar.value = heath

func set_level(lv: int, what):
	for att in atributes:
		match what:
			"current": att.level.current = lv
			"max": att.level.max = lv
			"min": att.level.min = lv

func set_active(mode):
		
	set_process(mode)
	set_physics_process(mode)
	
	visible = mode
	is_active = mode
		
	var layer = Globals.layers["enemy"] if mode else 0
	var mask = Globals.layers["player"] | Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["utils_wall"] | Globals.layers["armor"] if mode else 0
	
	body.collision_layer = layer
	body.collision_mask = mask

func take_damage(damage: float):
	
	if is_dead: return
	
	heath -= damage
	
	drop_damage_label(damage)
	
	if heath <= 0 and !is_dead:
		die()
	else:
		change_color_damage()

func knockback_logic():
	var knockback_dir = (body.global_position - player.player_body.global_position).normalized()
	body.velocity = knockback_dir * knockback_force
	
func die():
	
	if is_dead: return
				
	is_dead = true
	is_active = false
	
	set_physics_process(false)
	set_process(false)
	
	body.collision_layer = 0
	body.collision_mask = 0
	
	if not self is Boss:
		anim.play("die")
	anim.flip_h = last_dir.x > 0
	
	await anim.animation_finished

	visible = false
	enemy_die.emit(self)

func change_color_damage():
	body.move_and_slide()
	
	var sprite = anim
	var original_color = sprite.modulate

	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_color
	
func drop_damage_label(damage: float):
	var label := Label.new()
	label.text = str("-", damage)
	label.modulate = Color.RED
	
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 8
	
	call_deferred("add_child", label)
	
	var p0 = body.global_position
	var p1 = p0
	var p2 = p0
	
	p1.y -= 20
	p2.y -= 15
	
	var curve: MyCurve = MyCurve.new(p0, p1, p2)
	
	var tween = create_tween()
	tween.tween_method(_drop_damage_animation.bind(curve, label), 0.0, 1.0, 2)
	
	tween.tween_callback(label.queue_free)
	
func _drop_damage_animation(t: float, curve: MyCurve, label: Label):
	var p = curve.get_point(t)
	label.global_position = p
	
func dir_to_player() -> Vector2:
	return body.global_position.direction_to(Globals.player_pos())
	
func dist_to_player() -> float: 
	return body.global_position.distance_to(Globals.player_pos())
	
func setup():
	heath = heath_att.get_value()
	speed = speed_att.get_value()
	damage = damage_att.get_value()

func default_setup():
	pass
	
signal enemy_die(ene: Enemy)

class Attribute:
	
	var type: String
	var level: HasRange = HasRange.new()
	var value: HasRange = HasRange.new()

	func get_value():
				
		if level.current == 1:
			return value.min
						
		var mid = value.max - value.min
		
		var p = float(level.current) / level.max
		
		value.current = value.min + (mid * p)

		return value.current
		
	func set_max(max, what: String):
		match what:
			"value":
				value.max = max
			"level":
				level.max = max
				
	func set_min(min, what: String):
		match what:
			"value":
				value.min = min
			"level":
				level.min = min
				
	func setup(min, max, what):
		set_max(max, what)
		set_min(min,  what)
		
class HasRange:
	var current = 1
	var min = 0
	var max = 1
	
