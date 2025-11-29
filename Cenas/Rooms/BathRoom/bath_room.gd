extends Room

@export var shower_particles: CPUParticles2D
@export var shower_marker: Marker2D
@export var shower_light: PointLight2D

func _process(delta: float) -> void:
	if shower_marker.global_position.distance_to(Globals.player_pos()) < 30:
		if Input.is_action_just_pressed("ui_toggle_shower"):
			shower_particles.emitting = !shower_particles.emitting
			shower_light.visible = shower_particles.emitting

func set_active(mode: bool):
	super.set_active(mode)
	shower_particles.emitting = false
	shower_light.visible = false

	
