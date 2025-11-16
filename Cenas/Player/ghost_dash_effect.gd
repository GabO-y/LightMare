extends Node2D

@export var player: Player

func _process(delta: float) -> void:
	if player.is_dashing:
		
		var frames = player.anim.sprite_frames
		var anim_name = player.anim.animation
		var frame_id = player.anim.frame
		
		var texture = frames.get_frame_texture(anim_name, frame_id)
		
		var sprite = Sprite2D.new()
		
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		sprite.flip_h = player.dir.x > 0
		
		player.call_deferred("add_child", sprite)
		
		sprite.global_position = player.body.global_position - player.global_position
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0, 0.2)
		
		await tween.finished
		sprite.queue_free()
