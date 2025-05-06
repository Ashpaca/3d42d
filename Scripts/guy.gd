extends CharacterBody3D


const SPEED : float = 5.0
const JUMP_VELOCITY : float = 2.5
@onready var animator : AnimationPlayer = $Sprite3D/AnimationPlayer
@onready var shadowCaster : RayCast3D = $RayCasts/CenterRay
@onready var shadow : Sprite3D = $Shadow
@onready var jumpRays : Array[RayCast3D] = [$RayCasts/CenterRay,$RayCasts/BackRay,$RayCasts/RightRay,$RayCasts/FrontRay,$RayCasts/LeftRay]

func _ready() -> void:
	animator.play("stand_right")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, .1)
		velocity.z = move_toward(velocity.z, 0, .1)
	
	handleAnimations(input_dir)
	placeShadow()
	if is_on_floor():
		calculateJump(direction)
	
	move_and_slide()
	
	for collisionID in range(get_slide_collision_count()):
		if get_slide_collision(collisionID).get_collider() is RigidBody3D:
			var body : RigidBody3D = get_slide_collision(collisionID).get_collider() as RigidBody3D
			body.apply_central_force((body.global_position - Vector3(global_position.x, global_position.y - .5, global_position.z)).normalized().snapped(Vector3(1, 1, 1)) * 200)
			

func handleAnimations(inputVector : Vector2) -> void:
	if inputVector.length_squared() < .1:
		match animator.current_animation:
			"walk_left":
				animator.play("stand_left")
			"walk_right":
				animator.play("stand_right")
			"walk_up":
				animator.play("stand_up")
			"walk_down":
				animator.play("stand_down")
	elif abs(inputVector[0]) > abs(inputVector[1]):
		if inputVector[0] > 0:
			animator.play("walk_right")
		else:
			animator.play("walk_left")
	else:
		if inputVector[1] > 0:
			animator.play("walk_up")
		else:
			animator.play("walk_down")
		
func placeShadow() -> void:
	shadow.global_position = shadowCaster.get_collision_point() + Vector3(0, 0.1, 0)
	
func calculateJump(inputVector : Vector3) -> void:
	var raysOverEdge : Array[RayCast3D] = []
	var avgPoint : Vector3 = Vector3.ZERO
	for ray in jumpRays:
		if ray.is_colliding() and ((ray.global_position - ray.get_collision_point()).length_squared() > 1 or (ray.global_position - ray.get_collision_point()).length_squared() > 1):
			raysOverEdge.append(ray)
			avgPoint += ray.position
	var numPoints : int = len(raysOverEdge)
	if numPoints < 5 and numPoints > 2 and inputVector.dot(avgPoint) > 0:
		velocity += avgPoint.normalized() * 5
		velocity.y = JUMP_VELOCITY
	elif numPoints < 5 and numPoints > 2:
		velocity += avgPoint.normalized() * 1
	elif numPoints < 3:
		velocity -= avgPoint.normalized() * 1
		
			
		
		
