extends CharacterBody2D

signal enter_loading_zone
signal iron_released
signal steel_released
signal zinc_released
signal brass_released

# Progression Abilites
static var steel_unlocked = false
static var tin_unlocked = false
static var pewter_unlocked = false
static var zinc_unlocked = false
static var brass_unlocked = false
static var copper_unlocked = false
static var bronze_unlocked = false
static var cadmium_unlocked = false
static var bendalloy_unlocked = false
static var gold_unlocked = false
static var electrum_unlocked = false
static var chromium_unlocked = false
static var nicrosil_unlocked = false
static var aluminum_unlocked = false
static var duralumin_unlocked = false
static var atium_unlocked = false

# Parameters
@export var friction = 0.075
@export var move_force = 2000
@export var jump_force = -28000
@export var pull_push_force = 175000
@export var mass = 65
@export var throw_force = 400
@export var health = 100

# Instance variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var force_per_frame: Vector2
var selected_metal
var tin_active: = false
var has_jump = false
var is_stunned = false
var stun_timer = 0

func _ready():
	# Check if tin light needs to be enabled or not
	if get_tree().root.get_child(0).has_node("Darkness"):
		$PointLight2D.enabled = true
		
	for enemy in get_tree().get_nodes_in_group("Stunner"):
		print(enemy)
		enemy.stun_player.connect(get_stunned)

func _physics_process(_delta):
	force_per_frame = Vector2(0, 0)
	
	if is_stunned:
		print(stun_timer)
		stun_timer -= 1
		handle_gravity()
		handle_friction()
		velocity += force_per_frame / mass # Might need to do something to limit horizontal velocity specifically
		move_and_slide()
		
		if stun_timer <= 0:
			is_stunned = false
			
		return
	
	# Allomantic actions
	var current_target = get_target_from_group("Metal")
	if current_target:
		selected_metal = current_target
	handle_iron_input() # Iron is starting ability, unlocked from beginning of game.
	if steel_unlocked:
		handle_steel_input()
	if tin_unlocked:
		handle_tin_input()
	if zinc_unlocked:
		handle_zinc_input()
	if brass_unlocked:
		handle_brass_input()
		
	if is_on_floor():
		has_jump = true;
	
	# Other actions
	handle_loading_zone_input()
	handle_throw_coin_input()
	handle_jump_input()
	handle_move_input()
	
	# Finalize physics
	handle_gravity()
	handle_friction()
	velocity += force_per_frame / mass # Might need to do something to limit horizontal velocity specifically
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
		if has_jump:
			if pewter_unlocked:
				force_per_frame.y += (jump_force * 1.2)
			else:
				force_per_frame.y += jump_force
			has_jump = false

func handle_move_input():
	var direction = Input.get_axis("left", "right")
	if is_on_floor() || is_on_wall() || is_on_ceiling():
		if direction:
			force_per_frame.x = direction * move_force

func handle_throw_coin_input():
	if Input.is_action_just_pressed("throw_coin"):
		var direction = (get_viewport().get_mouse_position() - self.get_global_transform_with_canvas().origin).normalized()
		var coin = preload("res://Prefabs/coin.tscn").instantiate()
		
		iron_released.connect(coin.allomancy_released)
		steel_released.connect(coin.allomancy_released)
		
		get_tree().root.get_child(0).add_child(coin)
		coin.position = self.position + (direction * 34) # Math here to make spawning location work. Can't spawn inside floors or walls but need 360 degree for in air
		coin.apply_force(direction * throw_force)

func get_stunned():
	enter_loading_zone.emit() # This is soooooo bad but it might be the best way to do it
	iron_released.emit()
	steel_released.emit()
	zinc_released.emit()
	brass_released.emit()

	is_stunned = true
	stun_timer = 60

# Allomancy section
func handle_iron_input():
	if !selected_metal:
		return
	
	if Input.is_action_pressed("iron"):
		force_per_frame += selected_metal.pull(position, mass, pull_push_force)
	if Input.is_action_just_released("iron"):
		iron_released.emit()
		selected_metal = null

func handle_steel_input():
	if !selected_metal:
		return
	
	if Input.is_action_pressed("steel"):
		force_per_frame += selected_metal.push(position, mass, pull_push_force)
	if Input.is_action_just_released("steel"):
		steel_released.emit()
		selected_metal = null

func handle_tin_input():
	if Input.is_action_just_pressed("tin"):
		if tin_active:
			$PointLight2D.set_texture(preload("res://Art/basic_light.png"))
			tin_active = false
		else:
			$PointLight2D.set_texture(preload("res://Art/tin_light.png"))
			tin_active = true

func handle_zinc_input():
	if Input.is_action_just_pressed("zinc"):
		var enemy = get_target_from_group("Enemy")
		if enemy:
			enemy.change_AI_mode(enemy.AI_mode.aggressive)
			zinc_released.connect(enemy.reset_AI)
	elif Input.is_action_just_released("zinc"):
		zinc_released.emit()

func handle_brass_input():
	if Input.is_action_just_pressed("brass"):
		var enemy = get_target_from_group("Enemy")
		if enemy:
			enemy.change_AI_mode(enemy.AI_mode.passive)
			brass_released.connect(enemy.reset_AI)
	elif Input.is_action_just_released("brass"):
		brass_released.emit()

# Helpers
func get_target_from_group(group: String) -> Object:
	var distance_away = INF
	var selected_node = null
	
	for object in get_tree().get_nodes_in_group(group):
		var distance = get_viewport().get_mouse_position().distance_to(object.get_global_transform_with_canvas().origin)
		if distance < distance_away && distance < 75:
			distance_away = distance
			selected_node = object;
	
	return selected_node
