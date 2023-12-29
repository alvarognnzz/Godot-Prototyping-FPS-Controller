extends CharacterBody3D

enum State {IDLE, WALKING, JUMPING, SPRINTING, CROUCHING}

@export_group("Nodes")
@export var head: Node3D
@export var camera: Camera3D
@export var crouching_animation: AnimationPlayer
@export var crouching_shapecast: ShapeCast3D

@export_group("Properties")
@export_subgroup("Walking")
@export_range(1, 10, 0.1) var WALKING_SPEED: float = 4.5
@export_subgroup("Sprinting")
@export_range(1, 10, 0.1) var SPRINTING_SPEED: float = 6.0
@export_subgroup("Crouching")
@export_range(1, 10, 0.1) var CROUCHING_SPEED: float = 3.5
@export_range(1, 10, 0.1) var CROUCHING_ANIMATION_SPEED: float = 7.0
@export_subgroup("")
@export_range(1, 10, 0.1) var JUMP_VELOCITY: float = 4
@export_range(0, 1, 0.1) var MOUSE_SENSIBILITY: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_state = State.IDLE
var speed: float = WALKING_SPEED

var IS_CROUCHING: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSIBILITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSIBILITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouching_shapecast.add_exception($".")

func _physics_process(delta: float) -> void:
	$"../Label".text = State.keys()[current_state]
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	state_machine()

	if Input.is_action_just_pressed("jump") and is_on_floor() and current_state != State.CROUCHING:
		velocity.y = JUMP_VELOCITY
	
	move(speed)

	match current_state:
		State.IDLE:
			if IS_CROUCHING:
				crouch(false)
			pass
			
		State.WALKING:
			if IS_CROUCHING:
				crouch(false)
			speed = WALKING_SPEED
		
		State.JUMPING:
			pass
		
		State.SPRINTING:
			speed = SPRINTING_SPEED
		
		State.CROUCHING:
			speed = CROUCHING_SPEED
			if not IS_CROUCHING:
				crouch(true)

	move_and_slide()

func state_machine() -> void:
	if Input.get_vector("left", "right", "foward", "backward") == Vector2.ZERO and is_on_floor():
		current_state = State.IDLE
	if Input.get_vector("left", "right", "foward", "backward") != Vector2.ZERO and is_on_floor():
		current_state = State.WALKING
	if not is_on_floor():
		current_state = State.JUMPING
	if Input.is_action_pressed("sprint") and is_on_floor():
		current_state = State.SPRINTING
	if Input.is_action_pressed("crouch") or crouching_shapecast.is_colliding() and IS_CROUCHING and is_on_floor():
		current_state = State.CROUCHING

func move(speed: float) -> void:
	var input_dir: Vector2 = Input.get_vector("left", "right", "foward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func crouch(value: bool) -> void:
	if value == true:
		crouching_animation.play("crouch", -1, CROUCHING_ANIMATION_SPEED)
		IS_CROUCHING = true
	else:
		crouching_animation.play("crouch", -1, -CROUCHING_ANIMATION_SPEED, true)
		IS_CROUCHING = false
