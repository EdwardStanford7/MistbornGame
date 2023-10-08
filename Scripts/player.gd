extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var air_momentum: float = 60
@export var mass: float = 65
@export var pull_push_strength: float = 3000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var selected_metal

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump_input()
	handle_move_input(delta)
	handle_iron_steel_input()
	
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

func handle_iron_steel_input():
	var pulling = Input.is_action_pressed("pull")
	var pushing = Input.is_action_pressed("push")
	
	if pulling && pushing:
		return
		
	var target = get_target_metal()
	if target:
		selected_metal = target
			
	if !selected_metal:
		return
	
	if pulling:
		velocity += selected_metal.pull(position, mass, pull_push_strength)
		return
	
	if pushing:
		velocity += selected_metal.push(position, mass, pull_push_strength)
		return
		
	selected_metal = null

func get_target_metal() -> Object:
	var distance_away = INF
	var return_node = null
	
	for object in get_tree().get_nodes_in_group("Metal"):
		var distance = get_viewport().get_mouse_position().distance_to(object.get_global_transform_with_canvas().origin)
		if distance < distance_away && distance < 75:
			distance_away = distance
			return_node = object;
	return return_node
