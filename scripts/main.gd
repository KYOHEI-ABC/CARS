class_name Main
extends Node

const ROTATION_THRESHOLD: float = 0.03
const MODEL_Y_OFFSET: float = -0.5
const SELECTION_DISTANCE: float = 5.0

@export var camera: Camera3D
@export var models_node: Node

var pairs: Array[Dictionary]
var target_index: int = 0
var selected_bodies: Array[RigidBody3D]
var camera_offset: Vector3

func _ready() -> void:
	camera_offset = camera.position
	var body_scene = load("res://body.tscn")
	for model in models_node.get_children():
		var body = body_scene.instantiate() as RigidBody3D
		add_child(body)
		body.visible = false
		pairs.append({"body": body, "model": model})

func _process(_delta: float) -> void:
	camera.position = pairs[target_index].body.position + camera_offset
	for pair in pairs:
		var body: RigidBody3D = pair.body
		var model: Node3D = pair.model
		if -0.01 < body.linear_velocity.y and body.linear_velocity.y < 0.01:
			if randf() < 0.008:
				body.apply_central_impulse(Vector3(0, 5, 0))

		var diff = body.position - model.position
		model.position = body.position + Vector3(0, MODEL_Y_OFFSET, 0)

		diff.y = 0
		if diff.length_squared() > ROTATION_THRESHOLD * ROTATION_THRESHOLD:
			model.look_at(model.position + diff, Vector3.UP)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.keycode == KEY_SHIFT:
		if event.pressed:
			var target_pos = pairs[target_index].body.position
			selected_bodies.clear()
			for pair in pairs:
				if target_pos.distance_to(pair.body.position) <= SELECTION_DISTANCE:
					selected_bodies.append(pair.body)
		else:
			selected_bodies.clear()
		return

	if not event.pressed:
		return

	if event.keycode == KEY_ENTER:
		if selected_bodies.is_empty():
			target_index = (target_index + 1) % pairs.size()
		return

	if event.keycode == KEY_SPACE:
		for pair in pairs:
			var random_direction = Vector3(
				randf_range(-1.0, 1.0),
				0,
				randf_range(-1.0, 1.0)
			).normalized()
			pair.body.apply_central_impulse(random_direction * 8)
		return

	var direction = Vector3.ZERO
	match event.keycode:
		KEY_W: direction = Vector3(0, 0, -1)
		KEY_S: direction = Vector3(0, 0, 1)
		KEY_A: direction = Vector3(-1, 0, 0)
		KEY_D: direction = Vector3(1, 0, 0)

	if direction != Vector3.ZERO:
		var bodies = selected_bodies if not selected_bodies.is_empty() else [pairs[target_index].body]
		for body in bodies:
			body.apply_central_impulse(direction)
