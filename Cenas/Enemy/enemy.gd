extends Character

class_name Enemy

@export var speed = 200 #velocidade de movimentação
@export var damage = 1 #dano que o inimigo da

@export var body: CharacterBody2D #Corpo do inimigo
@export var anim: AnimatedSprite2D

@export var bar: ProgressBar #Barra de progresso

var is_stop = false

var player: Player #Proprio jogador

var position_target #Para onde ele deve andar
var is_attacking = false #para verificar se esta atacando o player para ter que ficar parado
var is_active: bool = false
var knockback_force: float = 500.0
var is_dead: bool = false
var last_dir: Vector2
#exclusivo dos fantasmas
var is_running_attack = false
var is_wrapped: bool = false

func _ready() -> void:
	
	player = Globals.player
	
	if level > 1:
		life *= 1 + (0.5 * level)
		damage *= 1 + (0.5 * level)
			
	for i in body.get_children():
		if i is ProgressBar:
			bar = i

	if bar != null:
		bar.max_value = life
		bar.value = life
	
func _process(_delta: float) -> void:
	update_bar()
	
func update_bar():
	if bar == null:
		return
	bar.value = life

func set_active(mode):
		
	set_process(mode)
	set_physics_process(mode)
	
	visible = mode
	is_active = mode
		
	var layer = Globals.layers["enemy"] if mode else 0
	var mask = Globals.layers["player"] | Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["utils_wall"] if mode else 0
	
	body.collision_layer = layer
	body.collision_mask = mask

	
func take_damage(damage: int):
	
	if is_dead: return
	
	life -= damage
	
	drop_damage_label(damage)
	
	if life <= 0 and !is_dead:
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

	enemy_die.emit(self)
		
	queue_free()

func change_color_damage():
	body.move_and_slide()
	
	var sprite = anim
	var original_color = sprite.modulate

	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_color
	
func drop_damage_label(damage: int):
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
	
signal enemy_die(ene: Enemy)
