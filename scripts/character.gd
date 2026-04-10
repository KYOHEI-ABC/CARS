class_name Character
extends Node

const MODELS: Array[PackedScene] = [
	preload("res://assets/cars/mcqueen.gltf"),
	preload("res://assets/cars/ramirez.gltf"),
	preload("res://assets/cars/storm.gltf"),
	preload("res://assets/tomica/buru.gltf"),
	preload("res://assets/tomica/dump.gltf"),
	preload("res://assets/tomica/police.gltf"),
	preload("res://assets/tomica/shobel.gltf"),
	preload("res://assets/anpanman/anpanman.gltf"),
	preload("res://assets/anpanman/baikinman.gltf"),
	preload("res://assets/anpanman/dokin.gltf"),
]
var index: int = 0

var body: RigidBody3D
var model: Node3D
var model_y_offset: float = -0.5

var spin_count: int = 0


func _init(index: int) -> void:
	self.index = index
	body = RigidBody3D.new()
	add_child(body)
	body.mass = 1
	body.gravity_scale = 1.2

	body.linear_damp = 0.1
	body.contact_monitor = true
	body.max_contacts_reported = 3
	body.body_entered.connect(_on_body_entered)


	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.8
	body.physics_material_override = physics_material


	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new()
	body.add_child(collision_shape)
	if 3 <= index and index <= 6:
		collision_shape.shape.radius = 1
		model_y_offset = -1

	model = MODELS[index].instantiate()
	add_child(model)


func _physics_process(delta: float) -> void:
	var diff = body.position - model.position
	model.position = body.position + Vector3(0, model_y_offset, 0)

	diff.y = 0
	if diff.length_squared() > 0.003:
		if spin_count == 0:
			model.look_at(model.position + diff, Vector3.UP)

	if spin_count > 0:
		spin_count -= 1
		model.rotation.y += 5

	if index == 5:
		var s = sin((2.0 * PI * Time.get_ticks_msec()) / 500.0)
		var current_scale = 1.0 + (s + 1.0) / 2.0 * (2.0 - 1.0)
		model.get_child(0).scale = Vector3.ONE * current_scale
	elif index == 6:
		var phase = (2.0 * PI * Time.get_ticks_msec()) / 1000.0
		model.get_child(4).rotation.x = deg_to_rad(60) + (deg_to_rad(30) * sin(phase))
	elif index >= 7:
		var arms: Array[Node3D] = []
		var legs: Array[Node3D] = []
		arms = [model.get_node("RightArm"), model.get_node("LeftArm")]
		legs = [model.get_node("RightLeg"), model.get_node("LeftLeg")]
		var progress = sin(2.0 * PI * Time.get_ticks_msec() / 500.0)
		arms[0].rotation_degrees.x = 45 * progress
		arms[1].rotation_degrees.x = -45 * progress
		legs[0].rotation_degrees.x = -45 * progress
		legs[1].rotation_degrees.x = 45 * progress
		
	if -0.01 < body.linear_velocity.y and body.linear_velocity.y < 0.01:
		if randf() < 0.008:
			body.apply_central_impulse(Vector3(0, 8, 0))


func _on_body_entered(_body: Node) -> void:
	if _body is StaticBody3D:
		return
	spin_count = 60

	var chara = _body.get_parent()
	if chara is Character:
		chara.spin_count = 60
