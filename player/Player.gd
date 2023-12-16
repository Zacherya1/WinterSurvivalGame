extends CharacterBody3D

@export var inventory_data: InventoryData

var speed
const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.0
const JUMP_VELOCITY = 2.5
const SENSITIVITY = 0.003

#plaer stat variables
var hunger: int = 100

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#footstep stuff
var can_play : bool = true
signal step

#inv stuff
signal toggle_inventory()

#fov variables
var BASE_FOV = 90.0
const FOV_CHANGE = 1.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var flashlight = $Head/Camera3D/SpotLight3D
@onready var interact_ray = $Head/Camera3D/InteractRay


func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(60))
	if Input.is_action_just_pressed("inv"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Handle Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
		
	#Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	flashlight.transform.origin = _headbobFlash(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbobFlash(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 1.5) * (BOB_AMP * 2)
	return pos

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	var low_pos = BOB_AMP - 0.05
	#check if we have reached a high point so we restart can_play
	if pos.y > -low_pos:
		can_play = true
	
	#check if the head position has reached a low point then turn off can play to avoid
	#multiple spam of thje emit signal
	if pos.y < -low_pos and can_play:
		can_play = false
		emit_signal("step")
	
	return pos

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact(self)

func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction

func eat(hunger_value: int) -> void:
	if hunger < 100:
		if (hunger_value + hunger) > 100:
			while (hunger_value + hunger) > 100:
				hunger -= 1
		else:
			hunger += hunger_value