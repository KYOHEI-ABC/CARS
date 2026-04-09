class_name Main
extends Node

## Configure rotation alignment threshold
const ROTATION_THRESHOLD: float = 0.03
const MODEL_Y_OFFSET: float = -0.5

@export var camera: Camera3D
var camera_offset: Vector3 = Vector3.ZERO

@export var models_node: Node

var pairs: Array[Dictionary] = [] # [{body: RigidBody3D, model: Node3D}]

func _ready() -> void:
	camera_offset = camera.position

	var body_scene = load("res://body.tscn")
	var models_list = models_node.get_children()

	for i in models_list.size():
		var model = models_list[i] as Node3D
		var body = body_scene.instantiate() as RigidBody3D
		add_child(body)
		pairs.append({"body": body, "model": model})


func _process(_delta: float) -> void:
	# Update model positions and rotations aligned with bodies
	for pair in pairs:
		var body = pair.body as RigidBody3D
		var model = pair.model as Node3D
		var body_pos = body.position

		# Update position with offset
		model.position = body_pos + Vector3(0, MODEL_Y_OFFSET, 0)

		# Only rotate if horizontal distance is significant
		var horizontal_diff = body_pos - model.position
		horizontal_diff.y = 0

		if horizontal_diff.length_squared() > ROTATION_THRESHOLD * ROTATION_THRESHOLD:
			model.look_at(model.position + horizontal_diff, Vector3.UP)

	camera.position = pairs[0].body.position + camera_offset

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return

	var direction = _get_movement_direction(event.keycode)

	if direction != Vector3.ZERO:
		for pair in pairs:
			pair.body.apply_central_impulse(direction)

func _get_movement_direction(keycode: Key) -> Vector3:
	match keycode:
		KEY_W:
			return Vector3(0, 0, -1)
		KEY_S:
			return Vector3(0, 0, 1)
		KEY_A:
			return Vector3(-1, 0, 0)
		KEY_D:
			return Vector3(1, 0, 0)
		_:
			return Vector3.ZERO
