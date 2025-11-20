extends CanvasLayer

@export var boss: Boss
@export var timer: Timer

var is_to_update: bool = true

func _ready() -> void:
	boss.is_damaged.connect(
		func():
			boss.life_bar.value = boss.heath
			timer.start()
	)

func _process(delta: float) -> void:
	if is_to_update:
		if boss.damage_bar.value > boss.life_bar.value:
			boss.damage_bar.value -= 0.2
		else:
			is_to_update = false

func _on_timer_to_update_life() -> void:
	is_to_update = true
	timer.stop()
