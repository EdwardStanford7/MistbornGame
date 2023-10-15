extends RigidBody2D

var net_force : Vector2 = Vector2.ZERO
var previous_linear_velocity : Vector2 = Vector2.ZERO
var being_affected = false

func _ready():
	self.body_entered.connect(on_body_entered)

func _integrate_forces(state):
	net_force = Vector2.ZERO
	
	if state.get_contact_count() > 0:
		var dv : Vector2 = state.linear_velocity - previous_linear_velocity
		net_force = mass * dv #/ state.step
	
	previous_linear_velocity = state.linear_velocity

func pull(player_position: Vector2, pull_strength: float) -> Vector2:
	var direction = player_position.direction_to(position)
	var force = pull_strength * direction / (position - player_position).length()
	
	if being_affected:
		force += force.project(force - net_force)
	being_affected = true
	
	self.apply_force(-force)
	return force

func push(player_position: Vector2, push_strength: float) -> Vector2:
	var direction = position.direction_to(player_position)
	var force = push_strength * direction / (position - player_position).length()
	
	if being_affected:
		force += force.project(force - net_force)
	being_affected = true
	
	self.apply_force(-force)
	return force

func on_body_entered(other):
	if other.is_in_group("Player"):
		self.queue_free()
