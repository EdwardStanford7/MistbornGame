extends StaticBody2D

@export var mass: float

func pull(player_position: Vector2, pull_strength: float, _player_mass) -> Vector2:
	var direction = position.direction_to(player_position)
	var distance = (position - player_position).length()
	
	return pull_strength * mass * -direction / distance

func push(player_position: Vector2, push_strength: float, _player_mass) -> Vector2:
	var direction = player_position.direction_to(position)
	var distance = (position - player_position).length()
	
	return push_strength * mass * -direction / distance
