extends RigidBody2D

var being_moved = false
var move_updates = 0
var previous_position = Vector2.ZERO

func _ready():
	self.body_entered.connect(on_body_entered)

func pull(player_position: Vector2, player_mass: float, pull_strength: float) -> Vector2:
	var self_percentage = player_mass / (mass + player_mass)
	var player_percentage = mass / (mass + player_mass)
	
	var distance_vector = position - player_position
	var direction = distance_vector.normalized()
	var distance_decay = distance_vector.length()
	
	var self_force = self_percentage * pull_strength * -direction / distance_decay
	
	var used_force
	if being_moved:
		used_force = (position - previous_position) * mass
		previous_position = position
	else:
		used_force = self_force
		move_updates += 1
		if move_updates > 5:
			being_moved = true
	
	var player_force = player_percentage * pull_strength * direction / distance_decay - (self_force - used_force)
	
	self.apply_force(self_force)
	return player_force

func push(player_position: Vector2, player_mass: float, push_strength: float) -> Vector2:
	var self_percentage = player_mass / (mass + player_mass)
	var player_percentage = mass / (mass + player_mass)
	
	var distance_vector = position - player_position
	var direction = distance_vector.normalized()
	var distance_decay = distance_vector.length()
	
	var self_force = self_percentage * push_strength * direction / distance_decay
	
	var used_force
	if being_moved:
		used_force = (position - previous_position) * mass
		previous_position = position
	else:
		used_force = self_force
		move_updates += 1
		if move_updates > 5:
			being_moved = true
	
	var player_force = player_percentage * push_strength * -direction / distance_decay - (self_force - used_force)

	self.apply_force(self_force)
	return player_force

func on_body_entered(other):
	if other.is_in_group("Player"):
		self.queue_free()
		
func allomancy_released():
	being_moved = false
	move_updates = 0
