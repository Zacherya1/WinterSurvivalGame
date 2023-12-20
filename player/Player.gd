extends CharacterBody3D

@export var inventory_data: InventoryData
@export var chest_equip_inventory_data: InventoryDataChestEquip
@export var head_equip_inventory_data: InventoryDataHeadEquip
@export var feet_equip_inventory_data: InventoryDataFeetEquip

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var flashlight = $Head/Camera3D/SpotLight3D
@onready var interact_ray = $Head/Camera3D/InteractRay
@onready var looking_at_item = $"../UI/Panel"
@onready var looking_at_item_text = $"../UI/Panel/Label"
@onready var inventory_interface = $"../UI/InventoryInterface"

#player stat variables
const MAX_STAMINA: int = 300
var hunger: float = 100
var stamina: int = MAX_STAMINA

#movement variables
const WALK_SPEED = 3.0
const JUMP_VELOCITY = 2.5
const SENSITIVITY = 0.003
var speed = 3.0
var sprint_speed = 4.0

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
const FOV_CHANGE = 1.1
var BASE_FOV = 90.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#handles inputs (button presses) for player actions
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
	
	#hunger reduces speed lower it is
	if hunger >= 0:
		hunger -= 0.01
	hungry()
	
	#While the inventory is closed, can do all player functions
	if inventory_interface.visible == false:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		#Handle Sprint + Stamina drain
		if Input.is_action_pressed("sprint"):
			if stamina > 0:
				speed = sprint_speed
				hunger -= 0.02
				stamina -= 1
		else:
			if stamina < MAX_STAMINA:
				stamina += 1
		
		
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
		var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
		move_and_slide()
	
	#TODO Consider making this block a seperate function
	#Looking at interactable - interact text?
	if interact_ray.is_colliding():
		if inventory_interface.visible == false:
			looking_at_item.visible = true
		else:
			looking_at_item.visible = false
		if interact_ray.get_collider():
			looking_at_item_text.text = interact_ray.get_collider().display_type + "\n\n" + interact_ray.get_collider().display_text
	else:
		looking_at_item.visible = false

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

#Speed drops as hunger drops to certain points
#function ran in physics process
#probs a better way to do this but oh well
func hungry() -> void:
	if hunger <= 0:
		speed = 0
		sprint_speed = 2.0
	elif hunger <= 25:
		speed = 1.5
		sprint_speed = 3.5
	elif hunger <= 50:
		speed = 2.0
		sprint_speed = 4.0
	elif hunger <= 75:
		speed = 2.5
		sprint_speed = 4.5
	elif hunger > 75:
		speed = 3.0
		sprint_speed = 5.0
	

#used for dropping stuff which is disabled rn
func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction

#right clicking a food item consumes it
func eat(hunger_value: int) -> void:
	AudioManager.MenuClickLow()
	AudioManager.Eat()
	if (hunger + hunger_value >= 100):
		hunger = 100
	else:
		hunger = hunger + hunger_value
