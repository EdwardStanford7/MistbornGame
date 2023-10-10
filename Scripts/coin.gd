extends RigidBody2D

var updates_since_effected = 0
var can_use_previous_position = false;
var previous_position: Vector2

func _ready():
	self.body_entered.connect(on_body_entered)
	
func _physics_process(_delta):
	updates_since_effected += 1
	if updates_since_effected == 2:
		can_use_previous_position = false

func pull(player_position: Vector2, player_mass: float, pull_strength: float) -> Vector2:
	updates_since_effected = 0
	
	var self_percentage = player_mass / (mass + player_mass)
	var player_percentage = mass / (mass + player_mass)
	
	var distance_vector = position - player_position
	var direction = distance_vector.normalized()
	var distance_decay = distance_vector.length()
	
	var self_force = self_percentage * pull_strength * -direction / distance_decay
	
	var used_force = Vector2(0, 0)
	if can_use_previous_position:
		used_force = (position - previous_position) * mass # might need a / delta here which since physics update will be 1/60
	else:
		used_force = self_force
	
	can_use_previous_position = true
	
	var player_force = player_percentage * pull_strength * direction / distance_decay - (self_force - used_force)
	
	self.apply_force(self_force)
	return player_force

func push(player_position: Vector2, player_mass: float, push_strength: float) -> Vector2:
	updates_since_effected = 0
	
	var self_percentage = player_mass / (mass + player_mass)
	var player_percentage = mass / (mass + player_mass)
	
	var distance_vector = position - player_position
	var direction = distance_vector.normalized()
	var distance_decay = distance_vector.length()
	
	var self_force = self_percentage * push_strength * direction / distance_decay
	
	var used_force = Vector2(0, 0)
	if can_use_previous_position:
		used_force = (position - previous_position) * mass # might need a / delta here which since physics update will be 1/60
	else:
		used_force = self_force
	
	can_use_previous_position = true
	
	var player_force = player_percentage * push_strength * -direction / distance_decay - (self_force - used_force)

	self.apply_force(self_force)
	return player_force

func on_body_entered(other):
	if other is CharacterBody2D:
		self.queue_free()
