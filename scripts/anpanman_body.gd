extends RigidBody3D

func _process(delta: float) -> void:
	if randf() < 0.01:
		apply_central_impulse(Vector3(0, 50, 0))
