class_name SpeedBubble
extends Area2D

func _ready():
	self.body_exited.connect(self.on_body_exit)

func on_body_exit(body):
	if body is Player:
		body.bendalloy_active = false
		self.queue_free()

func destroy():
	self.queue_free()
