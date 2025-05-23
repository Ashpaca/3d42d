class_name Guy extends CharacterBody3D


const SPEED : float = 5.0
const JUMP_VELOCITY : float = 2.5
const JUMP_COOLDOWN : float = 0.5
@onready var animator : AnimationPlayer = $Sprite3D/AnimationPlayer
@onready var shadowCaster : RayCast3D = $RayCasts/CenterRay
@onready var shadow : Sprite3D = $Shadow
@onready var jumpRays : Array[RayCast3D] = [$RayCasts/CenterRay,$RayCasts/BackRay,$RayCasts/RightRay,$RayCasts/FrontRay,$RayCasts/LeftRay]
@onready var lowFacingRay : RayCast3D = $RayCasts/LowFacing
@onready var highFacingRay : RayCast3D = $RayCasts/HighFacing
var timeSinceJump : float = 0.0
var inputDirection : Vector3 = Vector3.ZERO
var hasJustPressedInteract : bool = false
var isPressingInteract : bool = false
var pushPullObject : PushPull = null

func _ready() -> void:
	animator.play("stand_right")

func _process(_delta: float) -> void:
	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	if not pushPullObject:
		inputDirection = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		if abs(global_position.x - pushPullObject.global_position.x) > abs(global_position.z - pushPullObject.global_position.z):
			inputDirection = (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
		else:
			inputDirection = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
			
	if Input.is_action_just_pressed("interact"):
		hasJustPressedInteract = true
	isPressingInteract = Input.is_action_pressed("interact")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if inputDirection:
		velocity.x = inputDirection.x * SPEED
		velocity.z = inputDirection.z * SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, .1)
		velocity.z = move_toward(velocity.z, 0, .1)
	
	handleAnimations(inputDirection)
	placeShadow()
	if is_on_floor() and timeSinceJump > JUMP_COOLDOWN:
		calculateJump(inputDirection)
		jumpUp(inputDirection)
	
	if hasJustPressedInteract:
		hasJustPressedInteract = false
		facingPushPullObject()
	movePushPullObject(inputDirection)
			
	placeFacingRays(inputDirection)
	timeSinceJump += delta
	move_and_slide()
	
	'''
	for collisionID in range(get_slide_collision_count()):
		if get_slide_collision(collisionID).get_collider() is RigidBody3D:
			var body : RigidBody3D = get_slide_collision(collisionID).get_collider() as RigidBody3D
			body.apply_central_force((body.global_position - Vector3(global_position.x, global_position.y - .5, global_position.z)).normalized().snapped(Vector3(1, 1, 1)) * 200)
	#'''
			

func movePushPullObject(direction : Vector3) -> void:
	if not pushPullObject:
		return
	var dist : Vector3 = (pushPullObject.global_position - global_position)
	if dist.dot(direction) > .1:
		pushPullObject.apply_central_force(direction * 100)
	elif dist.dot(direction) < -.1:
		pushPullObject.apply_central_force(direction * 100)
		
		 

func facingPushPullObject() -> bool:
	var facingObject : Object = highFacingRay.get_collider()
	if facingObject is PushPull and not pushPullObject:
		pushPullObject = facingObject
		return true
	pushPullObject = null
	return false

func handleAnimations(direction : Vector3) -> void:
	if direction.length_squared() < .1:
		match animator.current_animation:
			"walk_left":
				animator.play("stand_left")
			"walk_right":
				animator.play("stand_right")
			"walk_up":
				animator.play("stand_up")
			"walk_down":
				animator.play("stand_down")
	elif abs(direction[0]) > abs(direction[2]):
		if direction[0] > 0:
			animator.play("walk_right")
		else:
			animator.play("walk_left")
	else:
		if direction[2] > 0:
			animator.play("walk_up")
		else:
			animator.play("walk_down")
		
func placeShadow() -> void:
	shadow.global_position = shadowCaster.get_collision_point() + Vector3(0, 0.1, 0)
	
func calculateJump(direction : Vector3) -> void:
	var raysOverEdge : Array[RayCast3D] = []
	var avgPoint : Vector3 = Vector3.ZERO
	for ray in jumpRays:
		if ray.is_colliding() and ((ray.global_position - ray.get_collision_point()).length_squared() > 1 or (ray.global_position - ray.get_collision_point()).length_squared() > 1):
			raysOverEdge.append(ray)
			avgPoint += ray.position
	var numPoints : int = len(raysOverEdge)
	if numPoints < 5 and numPoints > 2 and direction.dot(avgPoint) > 0:
		velocity += avgPoint.normalized() * 5
		velocity.y = JUMP_VELOCITY
	elif numPoints < 5 and numPoints > 2:
		velocity += avgPoint.normalized() * 1
	elif numPoints < 3:
		velocity -= avgPoint.normalized() * 1
		
func jumpUp(direction : Vector3):
	if lowFacingRay.is_colliding() and not highFacingRay.is_colliding() and direction.dot(lowFacingRay.get_collision_point() - global_position) > 0:
		velocity.y = JUMP_VELOCITY * 1.2
		timeSinceJump = 0.0

func placeFacingRays(direction : Vector3):
	if direction.length_squared() < 0.1:
		return
	lowFacingRay.target_position = direction * 0.7
	highFacingRay.target_position = direction * 0.7
