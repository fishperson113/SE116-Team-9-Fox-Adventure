extends BaseWeapon

var free_fire_effect: PackedScene = preload("res://scenes/player/effects/free_fire_effect.tscn")
@onready var fire_particles: GPUParticles2D = $Particles

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	var collision = move_and_collide(_velocity * delta)
	rotate(deg_to_rad(spin_speed))
	
	if collision:
		print(collision.get_collider())
		var created_effect = free_fire_effect.instantiate()
		if created_effect == null:
			return
	
		created_effect.global_position = position
		created_effect.scale.x = direction * created_effect.scale.x
		created_effect.z_index = -1
		get_tree().current_scene.add_child(created_effect)
		if created_effect is GPUParticles2D:
			created_effect.emitting = true
		get_tree().current_scene.add_child(fire_particles)
		queue_free()
