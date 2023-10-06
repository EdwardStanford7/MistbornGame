extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var air_momentum: float = 60

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			
	if Input.is_action_just_pressed("pull"):
		var target: Object = get_target_metal()
		print(target)
	if Input.is_action_just_pressed("push"):
		var target: Object = get_target_metal()
		print(target)
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
		else:
			velocity.x *= air_momentum * delta
	
	move_and_slide()

func get_target_metal() -> Object:
	var target_group: Array
	get_nodes_by_class(self.owner, "Metal", target_group)
	var distance_away = get_viewport().get_mouse_position().distance_to(target_group[0].global_transform.origin)
	var return_node = target_group[0]
	for index in target_group.size():
		var distance = get_viewport().get_mouse_position() .distance_to(target_group[index].global_transform.origin)
		if (distance < distance_away):
			distance_away = distance
			return_node = target_group[index];
	return return_node
	
func get_nodes_by_class(node: Node, className: String, result: Array):
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		get_nodes_by_class(child, className, result)
