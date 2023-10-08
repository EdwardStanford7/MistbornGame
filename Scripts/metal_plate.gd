extends StaticBody2D

var mass: float = INF

func pull(player_position: Vector2, _player_mass: float, pull_strength: float) -> Vector2:
	return pull_strength * (position - player_position).normalized() / (position - player_position).length()

func push(player_position: Vector2, _player_mass: float, push_strength: float) -> Vector2:
	return push_strength * (player_position - position).normalized() / (position - player_position).length()
