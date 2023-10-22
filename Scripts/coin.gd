class_name Coin
extends RigidBody2D

@export var allomancy_scaling_factor: float

var previous_linear_velocity : Vector2 = Vector2.ZERO
var force_since_last_frame: Vector2 = Vector2.ZERO
var player: CharacterBody2D
var stored_momentum: Vector2

func _ready():
	self.body_entered.connect(on_body_entered)

func _integrate_forces(state):
	if player:
		var net_force: Vector2 = (state.linear_velocity - previous_linear_velocity) * (1 / allomancy_scaling_factor) / state.step * mass
		var unknown_force := net_force - force_since_last_frame
		player.apply_force(unknown_force)
	
	previous_linear_velocity = state.linear_velocity
	force_since_last_frame = Vector2.ZERO

func pull(player_position: Vector2, pull_strength: float, player_mass: float) -> Vector2:
	var direction := position.direction_to(player_position)
	var distance := (position - player_position).length()
	
	force_since_last_frame += pull_strength * player_mass * direction / distance
	self.apply_force(pull_strength * allomancy_scaling_factor * player_mass * direction / distance)
	return pull_strength * mass * -direction / distance

func push(player_position: Vector2, push_strength: float, player_mass: float) -> Vector2:
	var direction := player_position.direction_to(position)
	var distance := (position - player_position).length()
	
	force_since_last_frame += push_strength * player_mass * direction / distance
	self.apply_force(push_strength * allomancy_scaling_factor * player_mass * direction / distance)
	return push_strength * mass * -direction / distance

func on_body_entered(other):
	if other is Player:
		self.queue_free()

func connect_player(caller: CharacterBody2D):
	if player:
		return
	self.player = caller

func allomancy_released():
	player = null

func activate_slow_time():
	stored_momentum = linear_velocity * mass
	set_deferred("freeze", true)

func deactivate_slow_time():
	set_deferred("freeze", false)
	apply_force(stored_momentum * 30) # Yes this hardcoded 30 is awful but like I'm not smart enough to make it work properly
