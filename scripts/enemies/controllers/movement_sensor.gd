class_name MovementSensor

# Raycast check wall and fall
var _front_ray_cast: RayCast2D = null
var _down_ray_cast: RayCast2D = null

func set_front_ray_cast(front_ray_cast: RayCast2D) -> void:
	_front_ray_cast = front_ray_cast
	
func set_down_ray_cast(down_ray_cast: RayCast2D) -> void:
	_down_ray_cast = down_ray_cast

func is_touch_wall() -> bool:
	if _front_ray_cast:
		return _front_ray_cast.is_colliding()
	return false

func is_can_fall() -> bool:
	if _down_ray_cast:
		return not _down_ray_cast.is_colliding()
	return false
