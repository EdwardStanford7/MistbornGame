class_name StunnerEnemy
extends Enemy

signal stun_player

func passive_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 1, 0))

func normal_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 2, 0))
	if randi() % 1000 == 0:
		stun_player.emit()

func aggressive_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 3, 0))
	if randi() % 300 == 0:
		stun_player.emit()
