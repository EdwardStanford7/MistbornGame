extends Area2D

@export var scene_to_load: String
@export var label: String

var player = null

func _ready():
	$Label.set_text(label)
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(other):
	if other is CharacterBody2D:
		player = other
		other.enter_loading_zone.connect(_on_enter)

func _on_body_exited(other):
	if (other == player):
		player = null
		other.enter_loading_zone.disconnect(_on_enter)

func _on_enter():
	get_tree().change_scene_to_file(scene_to_load)
