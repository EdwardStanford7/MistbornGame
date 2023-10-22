class_name Enemy
extends RigidBody2D
## This value is in meters per second
@export var movement_speed: int

enum AI_mode{
	passive,
	normal,
	aggressive
}

var current_AI := AI_mode.normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match current_AI:
		AI_mode.passive:
			passive_AI(_delta)
		AI_mode.normal:
			normal_AI(_delta)
		AI_mode.aggressive:
			aggressive_AI(_delta)

func passive_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 1, 0))

func normal_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 2, 0))

func aggressive_AI(delta):
	self.apply_force(Vector2((randi() % 3 - 1) * (mass * movement_speed / delta) * 3, 0))

func change_AI_mode(mode: AI_mode):
	current_AI = mode

func reset_AI():
	current_AI = AI_mode.normal
