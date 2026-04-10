extends RigidBody3D

func _ready() -> void:
	var mesh = $CollisionShape3D/MeshInstance3D

	var material = mesh.get_active_material(0).duplicate()

	# 2. ランダムな色を生成
	var random_color = Color.from_hsv(randf(), 1, 1)

	# 3. アルベド色（基本色）に設定
	material.albedo_color = random_color

	# 4. 複製したマテリアルを自分自身にセットし直す
	mesh.set_surface_override_material(0, material)
