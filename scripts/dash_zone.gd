extends Area3D


const IMPULSE_FORCE: float = 16.0

func _physics_process(_delta: float) -> void:
	var direction = _get_impulse_direction()

	for body in get_overlapping_bodies():
		if body is StaticBody3D:
			continue

		body.linear_velocity = Vector3.ZERO
		body.apply_central_impulse(direction)

func _get_impulse_direction() -> Vector3:
	var direction = - transform.basis.z.normalized()
	return direction.normalized() * IMPULSE_FORCE
