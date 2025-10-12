extends Line2D

func update_trajectory(dir: Vector2, speed: float, gravity: float, delta: float) -> void:
	var max_points = 200
	clear_points()
	var pos: Vector2 = Vector2.ZERO
	var vel = dir * speed
	for i in max_points:
		add_point(pos)
		vel.y += gravity * delta
		pos += vel * delta
