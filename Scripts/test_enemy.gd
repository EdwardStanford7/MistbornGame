extends RigidBody2D

@export var move_force: float = 2000

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

func aggressive_AI():
	self.apply_force(Vector2((randi() % 3 - 1) * move_force * 3, 0))

func change_AI_mode(mode: AI_mode):
	current_AI = mode

func reset_AI():
	current_AI = AI_mode.normal
