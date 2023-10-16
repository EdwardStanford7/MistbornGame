extends RigidBody2D

var net_force : Vector2 = Vector2.ZERO
var previous_linear_velocity : Vector2 = Vector2.ZERO
var being_affected = false
var player: CharacterBody2D

func _ready():
	self.body_entered.connect(on_body_entered)

func _integrate_forces(state): # Deal with transfering forces back to the player here
	net_force = Vector2.ZERO
	
	if state.get_contact_count() > 0:
		var dv : Vector2 = state.linear_velocity - previous_linear_velocity
		net_force = mass * dv #/ state.step
	
	previous_linear_velocity = state.linear_velocity

func pull(player_position: Vector2, pull_strength: float, player_mass: float) -> Vector2:
	var direction = position.direction_to(player_position)
	var distance = (position - player_position).length()
	
	self.apply_force(pull_strength * player_mass * direction / distance)
	return pull_strength * mass * -direction / distance

func push(player_position: Vector2, push_strength: float, player_mass: float) -> Vector2:
	var direction = player_position.direction_to(position)
	var distance = (position - player_position).length()
	
	self.apply_force(push_strength * player_mass * direction / distance)
	return push_strength * mass * -direction / distance

func on_body_entered(other):
	if other.is_in_group("Player"):
		self.queue_free()

func connect_player(player: CharacterBody2D):
	if being_affected:
		return
	player.metal_allomancy_released.connect(allomancy_released)
	self.player = player
	being_affected = true

func allomancy_released():
	player = null
	being_affected = false
