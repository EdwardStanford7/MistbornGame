extends RigidBody2D

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
	
	var used_force = (position - previous_position) * mass / 60
	previous_position = position
	
	var player_force = player_percentage * pull_strength * direction / distance_decay - (self_force - used_force)
	
	print(self_force)
	print(used_force)
	print(player_force)
	
	self.apply_force(self_force)
	return player_force

func push(player_position: Vector2, player_mass: float, push_strength: float) -> Vector2:
	var self_percentage = player_mass / (mass + player_mass)
	var player_percentage = mass / (mass + player_mass)
	
	var distance_vector = position - player_position
	var direction = distance_vector.normalized()
	var distance_decay = distance_vector.length()
	
	var self_force = self_percentage * push_strength * direction / distance_decay
	
	var used_force = (position - previous_position) * mass / 60
	previous_position = position
	
	var player_force = player_percentage * push_strength * -direction / distance_decay - (self_force - used_force)

	self.apply_force(self_force)
	return player_force

func on_body_entered(other):
	if other is CharacterBody2D:
		self.queue_free()
