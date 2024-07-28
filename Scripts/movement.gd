extends CharacterBody3D

var speed :float = 0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
var Jump_Availiable :bool = true
const SENSITIVITY = 0.003

#bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

#Fov
const BASE_FOV = 100.0
const FOV_CHANGE = 1.5

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var aninm = $AnimationPlayer
@onready var slide_col = $RayCast3D
#Slide
var falldistance = 0
var slide_speed = 0
var is_sliding :bool = false
var can_slide :bool = false
var falling : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x,
		deg_to_rad(-60),
		deg_to_rad(90)
		)
	
func _physics_process(delta):
	if(falling and is_on_floor() and is_sliding):
		slide_speed += falldistance / 10
	falldistance = -velocity.y
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		falling = true
	else:
		falling = false
	if Input.is_action_pressed("Sprint"):
		speed = lerp(speed,SPRINT_SPEED,delta * 2)
	else:
		speed = lerp(speed,WALK_SPEED,delta * 2)
	# Handle jump.
	jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	walk_run(direction,speed,delta)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("Click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	#slide
	if (Input.is_action_pressed("SlideCrouch") and speed >= 8):
		can_slide = true
	
	
	if (Input.is_action_pressed("SlideCrouch") and is_on_floor() and Input.is_action_pressed("Forward")):
		slide()
	
	#Head bob4
	if Input.is_action_pressed("Forward") or Input.is_action_pressed("Backward") or Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
	else:
		camera.transform.origin.x = lerp(camera.transform.origin.x,0.0,0.05)
		camera.transform.origin.y = lerp(camera.transform.origin.y,0.0,0.05)
		camera.transform.origin.z = lerp(camera.transform.origin.z,0.0,0.05)
	
	#Fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ)* BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

func slide():
	if not is_sliding:
		if slide_col.is_colliding() or get_floor_angle() < 0.2 :
			slide_speed = 5
			slide_speed += falldistance / 10 
		
func walk_run(direction,speed,delta):
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
func jump():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
