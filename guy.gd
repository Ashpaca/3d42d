extends CharacterBody3D


const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	for collisionID in range(get_slide_collision_count()):
		if get_slide_collision(collisionID).get_collider() is RigidBody3D:
			var body : RigidBody3D = get_slide_collision(collisionID).get_collider() as RigidBody3D
			body.apply_central_impulse((body.global_position - Vector3(global_position.x, global_position.y - .5, global_position.z)).normalized() * 2)
			
