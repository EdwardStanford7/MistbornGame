class_name SpeedBubble
extends Area2D

signal destroyed

@export var bubble_lifetime: float

var being_destroyed := false

func _ready():
	self.body_entered.connect(self.on_body_entered)
	self.body_exited.connect(self.on_body_exit)

func _physics_process(delta):
	if being_destroyed:
		return
	
	bubble_lifetime -= delta
	if bubble_lifetime <= 0:
		destroy()

func on_body_entered(body):
	if body is Coin || body is Enemy:
		body.deactivate_slow_time()

func on_body_exit(body):
	if being_destroyed:
		return
	
	if body is Player:
		destroy()
	elif body is Coin || body is Enemy:
		body.activate_slow_time()

func destroy():
	being_destroyed = true
	destroyed.emit()
	self.queue_free()
