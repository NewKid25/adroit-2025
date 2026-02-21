extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const JUMP_TIME = 0.1
const GRAVITY = 2000

var cd := Cooldown.new()
var jump_time := 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		cd.mark("jump", 0.1)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	
	if not Input.is_action_pressed("jump"):
		jump_time = 0
	
	if cd.check("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		cd.reset("jump")
		jump_time = JUMP_TIME
	
	jump_time -= delta
	if jump_time > 0:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	if Input.is_action_pressed("left"):
		direction -= 1
	if Input.is_action_pressed("right"):
		direction += 1
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
