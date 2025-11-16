extends TileMapLayer

@export var moveis_altos: TileMapLayer
@export var moveis_baixos: TileMapLayer

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return coords in moveis_altos.get_used_cells()  or coords in moveis_baixos.get_used_cells()
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
