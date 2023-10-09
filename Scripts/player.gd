extends CharacterBody2D

signal enter_loading_zone

@export var friction: float = 0.075
@export var speed_force: float = 200000 # ikik DC can suck a fat one
@export var jump_force: float = -2000000
@export var pull_push_force: float = 15000000
@export var mass: float = 65

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var force_per_frame: Vector2
var selected_metal
var tin_active: = false

func _physics_process(delta):
	handle_loading_zone_input()
	handle_tin_input()
	
	# Physics actions
	force_per_frame = Vector2(0, 0)
	
	handle_gravity()
	handle_jump_input()
	handle_move_input()
	handle_iron_steel_input()
	handle_friction()
	
	velocity += force_per_frame * delta / mass
	
	move_and_slide()

func handle_tin_input():
	if Input.is_action_just_pressed("tin"):
		if tin_active:
			self.get_child(3).set_texture(preload("res://Art/basic_light.png"))
			tin_active = false
		else:
			self.get_child(3).set_texture(preload("res://Art/tin_light.png"))
			tin_active = true

func handle_loading_zone_input():
	if Input.is_action_just_pressed("enter_loading_zone"):
		enter_loading_zone.emit()

func handle_friction():
	if is_on_floor() && force_per_frame.y > 0:
		force_per_frame.x -= friction * force_per_frame.y * velocity.x / 10
		return
	if is_on_ceiling() && force_per_frame.y < 0:
		force_per_frame.x -= friction * abs(force_per_frame.y) * velocity.x / 10
		return
		
	if is_on_wall():
		if force_per_frame.x < 0:
			force_per_frame.y -= friction * abs(force_per_frame.x) * velocity.y / 10
			return
		if force_per_frame.x > 0:
			force_per_frame.y -= friction * force_per_frame.x * velocity.y / 10
			return

func handle_gravity():
	force_per_frame.y += gravity

func handle_jump_input():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || is_on_wall():
			force_per_frame.y += jump_force

func handle_move_input():
	var direction = Input.get_axis("left", "right")
	if is_on_floor() || is_on_wall() || is_on_ceiling():
		if direction:
			force_per_frame.x = direction * speed_force

func handle_iron_steel_input():
	var pulling = Input.is_action_pressed("iron")
	var pushing = Input.is_action_pressed("steel")
	
	if pulling && pushing:
		return
		
	var target = get_target_metal()
	if target:
		selected_metal = target
			
	if !selected_metal:
		return
	
	if pulling:
		force_per_frame += selected_metal.pull(position, mass, pull_push_force)
		return
	
	if pushing:
		force_per_frame += selected_metal.push(position, mass, pull_push_force)
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
