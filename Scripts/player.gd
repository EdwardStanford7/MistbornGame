extends CharacterBody2D

signal enter_loading_zone

@export var friction: float = 0.075
@export var speed_force: float = 2000 # ikik DC can suck a fat one
@export var jump_force: float = -30000
@export var pull_push_force: float = 150000
@export var mass: float = 65
@export var throw_force: float = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var force_per_frame: Vector2
var selected_metal
var tin_active: = false

# Abilities unlocked section. Commented out ones are not implemented.
var steel_unlocked = false
var tin_unlocked = false
#var zinc_unlocked = false
#var brass_unlocked = false
#var copper_unlocked = false
#var bronze_unlocked = false
#var cadmium_unlocked = false
#var bendalloy_unlocked = false
#var gold_unlocked = false
#var electrum_unlocked = false
#var chromium_unlocked = false
#var nicrosil_unlocked = false
#var aluminum_unlocked = false
#var duralumin_unlocked = false
#var atium_unlocked = false

func _ready():
	# Check if light needs to be active or not
	if get_tree().root.get_child(0).has_node("Darkness"):
		self.get_child(3).enabled = true
	else:
		self.get_child(3).enabled = false

func _physics_process(_delta):
	force_per_frame = Vector2(0, 0)
	
	# Allomantic actions
	handle_iron_input() # Iron is starting ability, unlocked from beginning of game.
	if steel_unlocked:
		handle_steel_input()
	if tin_unlocked:
		handle_tin_input()
	
	# Other actions
	handle_loading_zone_input()
	handle_throw_coin_input()
	handle_jump_input()
	handle_move_input()
	
	# Finalize physics
	handle_gravity()
	handle_friction()
	velocity += force_per_frame / mass
	move_and_slide()

# Basic player functionality section
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

func handle_throw_coin_input():
	if Input.is_action_just_pressed("throw_coin"):
		var direction = (get_viewport().get_mouse_position() - self.get_global_transform_with_canvas().origin).normalized()
		var coin = preload("res://Prefabs/coin.tscn").instantiate()
		get_tree().root.get_child(0).add_child(coin)
		coin.position = self.position + (direction * 48) # Math here to make spawning location work. Can't spawn inside floors or walls but need 360 degree for in air
		coin.apply_force(direction * throw_force)

# Allomancy section
func handle_iron_input():
	var target = get_target_metal()
	if target:
		selected_metal = target
			
	if !selected_metal:
		return
	
	if Input.is_action_pressed("iron"):
		force_per_frame += selected_metal.pull(position, mass, pull_push_force)
		return
		
	selected_metal = null

func handle_steel_input():
	var target = get_target_metal()
	if target:
		selected_metal = target
			
	if !selected_metal:
		return
	
	if Input.is_action_pressed("steel"):
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

func handle_tin_input():
	if Input.is_action_just_pressed("tin"):
		if tin_active:
			self.get_child(3).set_texture(preload("res://Art/basic_light.png"))
			tin_active = false
		else:
			self.get_child(3).set_texture(preload("res://Art/tin_light.png"))
			tin_active = true

# pewter is passive upgrade, rest of activated abilites to follow.
