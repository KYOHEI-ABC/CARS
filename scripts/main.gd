class_name Main
extends Node

## Configure rotation alignment threshold
const ROTATION_THRESHOLD: float = 0.03
const MODEL_Y_OFFSET: float = -0.5
const SELECTION_DISTANCE: float = 8.0 # Shift押下時に周辺bodyを選択する距離

@export var camera: Camera3D
var camera_offset: Vector3 = Vector3.ZERO

@export var models_node: Node


var pairs: Array[Dictionary] = [] # [{body: RigidBody3D, model: Node3D}]
var camera_target_index: int = 0
var selected_bodies: Array[RigidBody3D] = [] # Shift押下時に選択されたbody
var shift_pressed: bool = false

func _ready() -> void:
	camera_offset = camera.position

	var body_scene = load("res://body.tscn")
	var models_list = models_node.get_children()

	for i in models_list.size():
		var model = models_list[i] as Node3D
		var body = body_scene.instantiate() as RigidBody3D
		add_child(body)
		body.visible = false
		pairs.append({"body": body, "model": model})


func _process(_delta: float) -> void:
	camera.position = pairs[camera_target_index].body.position + camera_offset

	for pair in pairs:
		var body = pair.body as RigidBody3D
		var model = pair.model as Node3D
		var body_pos = body.position

		# Only rotate if horizontal distance is significant
		var horizontal_diff = body_pos - model.position
		horizontal_diff.y = 0

		# Update position with offset
		model.position = body_pos + Vector3(0, MODEL_Y_OFFSET, 0)

		if horizontal_diff.length_squared() > ROTATION_THRESHOLD * ROTATION_THRESHOLD:
			model.look_at(model.position + horizontal_diff, Vector3.UP)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Shift キーの処理
		if event.keycode == KEY_SHIFT:
			if event.pressed:
				shift_pressed = true
				_select_nearby_bodies()
			else:
				shift_pressed = false
				selected_bodies.clear()
			return

	if not event is InputEventKey or not event.pressed:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if not shift_pressed:
				camera_target_index = (camera_target_index + 1) % pairs.size()
			return

	var direction = _get_movement_direction(event.keycode)

	if direction != Vector3.ZERO:
		if shift_pressed and selected_bodies.size() > 0:
			for body in selected_bodies:
				body.apply_central_impulse(direction * 1)
		else:
			pairs[camera_target_index].body.apply_central_impulse(direction * 1)

func _select_nearby_bodies() -> void:
	selected_bodies.clear()
	var target_body = pairs[camera_target_index].body
	var target_pos = target_body.position

	for pair in pairs:
		var body = pair.body as RigidBody3D
		var distance = target_pos.distance_to(body.position)
		if distance <= SELECTION_DISTANCE:
			selected_bodies.append(body)

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
