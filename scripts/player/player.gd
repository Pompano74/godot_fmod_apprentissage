extends CharacterBody3D


const SPEED = 325.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.0035

var footStepTimer: float = 0.0
var footStepTimerReset: float = 0.35

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var raycast: RayCast3D = $RayCast3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if footStepTimer <= 0.0:
			if raycast.is_colliding():
				var obj = raycast.get_collider()
				if "surfaceType" in obj:
					match obj.surfaceType:
						"Carpet":
							$sounds/footSteps.set_parameter("surface_type", 0.0)
							print(obj.surfaceType)
						"Grass":
							$sounds/footSteps.set_parameter("surface_type", 0.1)
							print(obj.surfaceType)
						"Wood":
							$sounds/footSteps.set_parameter("surface_type", 0.2)
							print(obj.surfaceType)
					$sounds/footSteps.play()
					footStepTimer = footStepTimerReset
		footStepTimer -= delta
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
