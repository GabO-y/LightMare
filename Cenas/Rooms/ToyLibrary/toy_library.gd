extends Room

@export var utils: Node2D
@export var moveis_altos: TileMapLayer

var nav_modified: bool = true
var pos_cells: Array[Vector2i]
