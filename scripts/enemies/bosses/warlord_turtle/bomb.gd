extends BaseBullet

@export var explosion_radius: float = 100.0
@export var tile_effect: PackedScene = null
@export var duration: float = 3.0

func _on_body_entered(_area: Variant) -> void:
	super._on_body_entered(_area)
	if _area is TileMapLayer:
		call_deferred("create_effect_tiles", get_nearest_filled_tiles(_area, global_position, explosion_radius), duration)

func create_effect_tiles(_positions: Array[Vector2], _duration: float):
	var tiles: Array
	for pos in _positions:
		tiles.append(create(tile_effect, pos))

	get_tree().create_timer(_duration).timeout.connect(
		func():
			for tile in tiles:
				if is_instance_valid(tile):
					tile.queue_free()
	)

func get_nearest_filled_tiles(_tile_map: TileMapLayer, _position: Vector2, _radius: float):
	# start traversing at the leftmost cell and end at the rightmost cell by radius
	var start_point = _tile_map.local_to_map(_tile_map.to_local(_position - Vector2(_radius, _radius)))
	var end_point = _tile_map.local_to_map(_tile_map.to_local(_position + Vector2(_radius, _radius)))
	
	var nearest_pos: Array[Vector2]
	for row in range(start_point.x, end_point.x):
		for col in range(start_point.y, end_point.y):
			# skip if the cell does not exist
			var cell_map_coord := Vector2i(row, col)
			if _tile_map.get_cell_source_id(cell_map_coord) == -1:
				continue
			# skip if the above cell exists
			var above_map_coord := Vector2i(cell_map_coord.x, cell_map_coord.y - 1)
			if _tile_map.get_cell_source_id(above_map_coord) != -1:
				continue
			# skip if the cell is out range
			var cell_global_coord := _tile_map.to_global(_tile_map.map_to_local(cell_map_coord))
			if cell_global_coord.distance_to(_position) > _radius:
				continue
			
			nearest_pos.append(cell_global_coord)
	
	return nearest_pos

func _on_hurt_area_2d_hurt(attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	velocity = _direction * abs(velocity)
