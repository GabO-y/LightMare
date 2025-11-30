extends Menu

class_name ChestMenu

@export var armor_menu: ArmorChestMenu

@export var popup: Label
@export var menu: Container
@export var area: Area2D
@export var tabCont: TabContainer

@export var wearpowns_node: HFlowContainer
@export var power_ups_node: HFlowContainer

@export var inssu_coins_point: Marker2D
@export var coins_label: Label

@export var player: Player

var test: Array[Dictionary]
var is_test = false

var is_visible_pop_up = false

var is_issu_coin = false
var timer_issu_coin = 0.0
var duration_issu_coin = 1

var can_shake_coins: bool = true
var shake_coin_coldown: float = 1
var shake_coin_timer: float = 0.0
var label_coin_pos: Vector2

func _ready() -> void:
	

	menu.process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().process_frame
	
	Globals.player.armor_manager.chess_menu = self
	
	set_active(false)
	hide_pop_up()
	
	armor_menu.armor_manager = player.armor_manager
	
	armor_menu.setup_sizes()
	
	armor_menu._update("lantern")
		
	player.spend_coins.connect(_update_label_coins)
	
func _update_label_coins(amount: int):
	coins_label.text = str(player.coins)
	
	
func _process(delta: float) -> void:
	
	if is_test:
		for i in test:
			var l = i["label"] as Label
			var c = i["curve"] as MyCurve
			l.position = c.get_point_by_progress()
			
		if test.is_empty():
			is_test = false
			
	if not can_shake_coins:
		shake_coin_timer += delta
		if shake_coin_timer > shake_coin_coldown:
			can_shake_coins = true
			shake_coin_timer = 0
			
			coins_label.global_position = label_coin_pos
		
	if is_issu_coin:
		if timer_issu_coin > duration_issu_coin:
			timer_issu_coin = 0
			is_issu_coin = false
			return
		timer_issu_coin += delta
			
	if Globals.player == null: return
	
	var dist = area.global_position.distance_to(Globals.player_pos())
			
	if dist < 30 and not is_visible_pop_up:
		show_popup()
		is_visible_pop_up = true
		
	if dist > 30 and is_visible_pop_up:
		hide_pop_up()
		is_visible_pop_up = false
		
	if is_visible_pop_up and Input.is_action_just_pressed("ui_menu"):
		if manager.is_in_menu: return
		hide_pop_up()
		enable()
				
	if Globals.player.is_in_menu and Input.is_action_just_pressed("ui_exit_menu"):
		disable()

func show_popup():	
	set_visible_pop_up(true)
	
func hide_pop_up():
	set_visible_pop_up(false)
	
func show_menu():
	if !menu: return
	set_active(true)

func hide_menu():
	if !menu: return
	set_active(false)

	
func set_visible_pop_up(mode: bool):
	if popup == null: return
	popup.visible = mode
	
func set_visible_menu(mode: bool):
	if menu == null: return
	if Globals.player:
		Globals.player.is_in_menu = mode
	menu.visible = mode
	
func _on_wearpons_button_down() -> void:
	tabCont.current_tab = 0

func _on_power_ups_button_down() -> void:
	tabCont.current_tab = 1
	
func disable():
	set_active(false)
	
func enable():
	set_active(true)
	
func set_active(mode: bool):
	
	var is_safe_room = Globals.room_manager.current_room.name == "SafeRoom"
	if not is_safe_room: 
		mode = false
	
	super.set_active(mode)
	set_visible_menu(mode)
	update_label_coins()
	$MarginContainer/VBoxMain/Options/Wearpons.grab_focus()

func _buy_item(item: ChestItem):
	
	Globals.player.coins -= item.price
	update_label_coins()
	
	match item.name:
		"vida":
			Globals.player.update_hearts()
	
	item.queue_free()
	
func _insuffient_coisn():
		
	shake_coins()
	
	if is_issu_coin:
		return
		
	is_issu_coin = true

	var label = Label.new()
	add_child(label)
	
	label.global_position = inssu_coins_point.global_position
	label.text = "Pontos insuficientes"
	label.modulate = Color.ORANGE_RED
	
	var curve = MyCurve.new()
		
	curve.set_t(0.005)
	
	var heigth = randi_range(500, 1000)
	var wight = randi_range(0, 1000)
	var right = [true, false].pick_random()
	
	curve.drop_effect(inssu_coins_point.global_position, right, wight, heigth)
	
	var tween = create_tween()
	tween.tween_method(_curve_text.bind(curve, label), 0.0, 1.0, 2.5)
	
	tween.tween_callback(label.queue_free)
	
func _curve_text(t: float, curve_param: MyCurve, text_label: Label):
	var curve_pos = curve_param.get_point(t)
	text_label.global_position = curve_pos
	
func shake_coins():
	if can_shake_coins:
		label_coin_pos = coins_label.global_position
		shake_object(coins_label)
		can_shake_coins = false

func shake_object(target, duration: float = 0.5, magnitude: float = 10.0) -> void:
	var tween = create_tween()
	var original_pos = target.position
	var shakes = int(duration / 0.05)
	for i in range(shakes):
		var offset = Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		tween.tween_property(target, "position", original_pos + offset, 0.025)
		tween.tween_property(target, "position", original_pos, 0.025)
	
func _on_wearpons_pressed() -> void:
	tabCont.current_tab = 0

func _on_power_ups_pressed() -> void:
	tabCont.current_tab = 1

func update_label_coins():
	Globals.player.update_label_coins()
	coins_label.text = str(Globals.player.coins)
