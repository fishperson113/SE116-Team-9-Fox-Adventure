extends BaseWeapon

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	var collision = move_and_collide(_velocity * delta)
	rotate(deg_to_rad(spin_speed))
	
	if collision:
		var collision_direction = collision.get_normal()
		var collectible_blade = sample_collectible_weapon.instantiate()
		collectible_blade.global_position = global_position
		collectible_blade.rotation = collision_direction.angle() + PI
		collectible_blade.add_item_detail(weapon_detail)
		get_tree().current_scene.add_child(collectible_blade)
		queue_free()
