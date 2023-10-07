extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var air_momentum: float = 60
@export var mass: float = 65
@export var pull_push_strength: float = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump_input()
	handle_move_input(delta)
	handle_iron_steel_input(delta)
	
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump_input():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity

func handle_move_input(delta):
	var direction = Input.get_axis("left", "right")
	if is_on_floor():
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x *= air_momentum * delta

func handle_iron_steel_input(delta):
	if Input.is_action_just_pressed("pull") && Input.is_action_just_pressed("push"):
		return
	
	if Input.is_action_just_pressed("pull"):
		print("pull")
		var target: Object = get_target_metal()
		if target:
			print(target)
	
	if Input.is_action_just_pressed("push"):
		print("push")
		var target: Object = get_target_metal()
		if target:
			print(target)

func get_target_metal() -> Object:
	var target_group: Array = get_tree().get_nodes_in_group("Metal");
	if target_group.is_empty():
		return null
	var distance_away = get_viewport().get_mouse_position().distance_to(target_group[0].get_global_transform_with_canvas().origin)
	var return_node = target_group[0]
	for index in target_group.size():
		var distance = get_viewport().get_mouse_position().distance_to(target_group[index].get_global_transform_with_canvas().origin)
		if (distance < distance_away):
			distance_away = distance
			return_node = target_group[index];
	return return_node
