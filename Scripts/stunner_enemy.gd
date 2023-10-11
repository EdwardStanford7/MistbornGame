extends RigidBody2D

signal stun_player

@export var move_force: float

enum AI_mode{
	passive,
	normal,
	aggressive
}

var current_AI = AI_mode.normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match current_AI:
		AI_mode.passive:
			passive_AI()
		AI_mode.normal:
			normal_AI()
		AI_mode.aggressive:
			aggressive_AI()

func passive_AI():
	pass # Simple test, enemy will do nothing in this state

func normal_AI():
	self.apply_force(Vector2((randi() % 3 - 1) * move_force, 0))
	if randi() % 1000 == 0:
		stun_player.emit()

func aggressive_AI():
	self.apply_force(Vector2((randi() % 3 - 1) * move_force * 3, 0))
	if randi() % 300 == 0:
		stun_player.emit()

func change_AI_mode(mode: AI_mode):
	current_AI = mode

func reset_AI():
	current_AI = AI_mode.normal
