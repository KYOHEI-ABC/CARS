class_name Main
extends Node

@onready var camera = $Environment/Camera3D
var camera_offset: Vector3

var characters: Array[Character] = []

var target_index: int = 0
var target_indexes: Array[int] = []

func _ready() -> void:
	camera_offset = camera.position

	for i in range(Character.MODELS.size()):
		characters.append(Character.new(i))
	for character in characters:
		add_child(character)
		character.body.position.x = (randf() - 0.5) * 50
		character.body.position.z = (randf() - 0.5) * 50
		character.body.position.y = 16

	for i in range(32):
		var ball = load("res://ball.tscn").instantiate()
		add_child(ball)
		ball.position.x = (randf() - 0.5) * 50
		ball.position.z = (randf() - 0.5) * 50
		ball.position.y = 16

	for i in range(32):
		var dz = load("res://dash_zone.tscn").instantiate()
		add_child(dz)
		dz.position.x = (randf() - 0.5) * 50
		dz.position.z = (randf() - 0.5) * 50

		dz.rotation.y = deg_to_rad(randf() * 360)


func _process(_delta: float) -> void:
	camera.position = characters[target_index].body.position + camera_offset


func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if event.keycode == KEY_SHIFT:
		if event.pressed:
			var target_pos = characters[target_index].body.position
			target_indexes.clear()
			for i in range(characters.size()):
				if target_pos.distance_to(characters[i].body.position) <= 16:
					target_indexes.append(i)
		else:
			target_indexes.clear()
		return

	if event.pressed and event.keycode == KEY_ENTER:
		if target_indexes.size() == 0:
			target_index = (target_index + 1) % characters.size()

	if event.pressed and event.keycode == KEY_SPACE:
		for chara in characters:
			var random_direction = Vector3(
				randf_range(-1.0, 1.0),
				0,
				randf_range(-1.0, 1.0)
			).normalized()
			if chara.body.linear_velocity.length_squared() <= 128:
				chara.body.apply_central_impulse(random_direction * 16)

	var direction = Vector3.ZERO
	if event.pressed:
		if event.keycode == KEY_W:
			direction = Vector3(0, 0, -1)
		elif event.keycode == KEY_S:
			direction = Vector3(0, 0, 1)
		elif event.keycode == KEY_A:
			direction = Vector3(-1, 0, 0)
		elif event.keycode == KEY_D:
			direction = Vector3(1, 0, 0)
	if target_indexes.size() > 0:
		for i in target_indexes:
			var body = characters[i].body
			if body.linear_velocity.length_squared() <= 128:
				body.apply_central_impulse(direction * 3)
	else:
		var body = characters[target_index].body
		if body.linear_velocity.length_squared() <= 128:
			body.apply_central_impulse(direction * 3)
