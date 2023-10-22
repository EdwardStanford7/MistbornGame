class_name Player
extends CharacterBody2D

signal enter_loading_zone
signal metal_allomancy_released
signal zinc_released
signal brass_released
signal bendalloy_released

# Progression Abilites
static var steel_unlocked := false
static var tin_unlocked := false
static var pewter_unlocked := false
static var zinc_unlocked := false
static var brass_unlocked := false
static var copper_unlocked := false
static var bronze_unlocked := false
static var cadmium_unlocked := false
static var bendalloy_unlocked := false
static var gold_unlocked := false
static var electrum_unlocked := false
static var chromium_unlocked := false
static var nicrosil_unlocked := false
static var aluminum_unlocked := false
static var duralumin_unlocked := false
static var atium_unlocked := false

# Parameters
@export var friction_coefficient: float
## This value is in meters per second
@export var movement_speed: int
## This value is in meters per second
@export var jump_speed: int
## This value is in newtons
@export var pull_push_force: int
## This value is inkilograms
@export var mass: int
## This value is in newtons
@export var throw_speed: int
## This value is in physics update frames (1/60 second)
@export var stun_time: int
## This value is in physics update frames (1/60 second)
@export var coyote_time: int
@export var health: int
@export var pewter_scaling: float

# Instance variables
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var force_per_frame: Vector2
var selected_metal
var tin_active := false
var bendalloy_active := false
var is_stunned := false
var stun_timer := 0
var has_jump := false
var coyote_timer := 0

func _ready():
	# Check if tin light needs to be enabled or not
	if get_tree().root.get_child(0).has_node("Darkness"):
		$PointLight2D.enabled = true
		
	for enemy in get_tree().get_nodes_in_group("Stunner"):
		enemy.stun_player.connect(get_stunned)

func _physics_process(_delta):
	coyote_update()
	
	if is_stunned:
		stun_update(_delta)
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
	if bendalloy_unlocked:
		handle_bendalloy_input()
	
	# Other actions
	handle_loading_zone_input()
	handle_throw_coin_input(_delta)
	handle_jump_input(_delta)
	handle_move_input(_delta)
	
	# Finalize physics
	compute_physics(_delta)

# Basic player functionality section
func handle_loading_zone_input():
	if Input.is_action_just_pressed("enter_loading_zone"):
		enter_loading_zone.emit()

func handle_friction():
	if is_on_floor() || is_on_ceiling():
		velocity.x *= friction_coefficient
		return
	
	if is_on_wall():
		velocity.y *= friction_coefficient
		return

func handle_gravity():
	force_per_frame.y += gravity * mass

func handle_jump_input(delta):
	if Input.is_action_just_pressed("jump"):
		if has_jump:
			if pewter_unlocked:
				force_per_frame.y -= (jump_speed / delta) * pewter_scaling * mass
			else:
				force_per_frame.y -= (jump_speed / delta) * mass
			has_jump = false

func handle_move_input(delta):
	var direction := Input.get_axis("left", "right")
	if has_jump:
		if direction:
			force_per_frame.x = direction * mass * (movement_speed / delta)

func handle_throw_coin_input(delta):
	if Input.is_action_just_pressed("throw_coin"):
		var direction := (get_viewport().get_mouse_position() - self.get_global_transform_with_canvas().origin).normalized()
		var coin: Coin = load("res://Prefabs/coin.tscn").instantiate()
		
		get_tree().root.get_child(0).add_child(coin)
		metal_allomancy_released.connect(coin.allomancy_released)
		coin.position = self.position + (direction * 35) # Math here to make spawning location work. Can't spawn inside floors or walls but need 360 degree for in air
		coin.apply_force(direction * coin.mass * (throw_speed / delta))

# Allomancy section
func handle_iron_input():
	if !selected_metal:
		return
	
	if Input.is_action_pressed("iron"):
		if selected_metal is Coin:
			selected_metal.connect_player(self)
		
		if pewter_unlocked:
			force_per_frame += selected_metal.pull(position, pull_push_force * pewter_scaling, mass)
		else:
			force_per_frame += selected_metal.pull(position, pull_push_force, mass)
	
	if Input.is_action_just_released("iron"):
		selected_metal = null
		metal_allomancy_released.emit()

func handle_steel_input():
	if !selected_metal:
		return
	
	if Input.is_action_pressed("steel"):
		if selected_metal is Coin:
			selected_metal.connect_player(self)
		
		if pewter_unlocked:
			force_per_frame += selected_metal.push(position, pull_push_force * pewter_scaling, mass)
		else:
			force_per_frame += selected_metal.push(position, pull_push_force, mass)

	
	if Input.is_action_just_released("steel"):
		selected_metal = null
		metal_allomancy_released.emit()

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

func handle_bendalloy_input():
	if Input.is_action_just_pressed("bendalloy"):
		if bendalloy_active:
			bendalloy_released.emit()
			bendalloy_active = false
		else:
			var speed_bubble: SpeedBubble = load("res://Prefabs/speed_bubble.tscn").instantiate()
			speed_bubble.position = self.position
			bendalloy_released.connect(speed_bubble.destroy)
			get_tree().root.get_child(0).add_child(speed_bubble)
			bendalloy_active = true

# Helpers
func compute_physics(delta):
	handle_gravity()
	velocity += force_per_frame * (delta / mass)
	handle_friction()
	move_and_slide()
	force_per_frame = Vector2(0, 0)

func apply_force(force: Vector2):
	force_per_frame += force

func get_target_from_group(group: String) -> Object:
	var distance_away := INF
	var selected_node = null
	
	for object in get_tree().get_nodes_in_group(group):
		var distance := get_viewport().get_mouse_position().distance_to(object.get_global_transform_with_canvas().origin)
		if distance < distance_away && distance < 75:
			distance_away = distance
			selected_node = object;
	
	return selected_node

func is_grounded():
	return abs(velocity.y) < 0.1

func get_stunned():
	if !tin_active:
		return
	
	zinc_released.emit()
	brass_released.emit()
	
	is_stunned = true
	stun_timer = stun_time

func stun_update(_delta):
	stun_timer -= 1
	compute_physics(_delta)
	if stun_timer <= 0:
		is_stunned = false

func coyote_update():
	if is_grounded():
		has_jump = true
		coyote_timer = coyote_time
	
	if !(is_on_floor() || is_on_wall() || is_on_ceiling()) && coyote_timer > 0:
		coyote_timer -= 1
		if coyote_timer == 0:
			has_jump = false
