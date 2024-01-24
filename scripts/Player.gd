class_name Player
extends CharacterBody3D


## Character maximum run speed on the ground.
@export var move_speed := 4.0
## Movement acceleration (how fast character achieve maximum speed)
@export var acceleration := 2.0
## Jump impulse
@export var jump_initial_impulse := 8.0
## Jump impulse when player keeps pressing jump
@export var jump_additional_force := 2.5
## Player model rotaion speed
@export var rotation_speed := 8.0
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export var stopping_speed := 1.0

# @onready var _step_sound: AudioStreamPlayer3D = $StepSound
# @onready var _landing_sound: AudioStreamPlayer3D = $LandingSound
@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin

@onready var _move_direction := Vector3.ZERO
@onready var _last_strong_direction := Vector3.FORWARD
@onready var _gravity: float = -30.0
@onready var _ground_height: float = 0.0
@onready var _start_position := global_transform.origin
@onready var _is_on_floor_buffer := false

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	
func _physics_process(delta: float) -> void:
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_just_on_floor := is_on_floor() and not _is_on_floor_buffer
	
	_is_on_floor_buffer = is_on_floor()
	_move_direction = _get_move_direction()
	
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	
	_orient_character_to_direction(_last_strong_direction, delta)
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	if _move_direction.length() == 0 and velocity.length() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity
	
	velocity.y += _gravity * delta
	
	if is_just_jumping:
		velocity.y += jump_initial_impulse
		
	# Set character animation
	if is_just_jumping:
		_character_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_character_skin.fall()
	elif is_on_floor():
		var xz_velocity := Vector3(velocity.x, 0, velocity.z)
		if xz_velocity.length() > stopping_speed:
			_character_skin.set_moving(true)
			# _character_skin.set_moving_speed(inverse_lerp(0.0, move_speed, xz_velocity.length()))
		else:
			_character_skin.set_moving(false)
			
	if is_just_on_floor:
		pass
		# _landing_sound.play()
		
	var position_before := global_position
	move_and_slide()
	var position_after := global_position
	
	# If velocity is not 0 but the difference of positions after move_and_slide is,
	# character might be stuck somewhere!
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1
		
func reset_position() -> void:
	transform.origin = _start_position
	
func _get_move_direction() -> Vector3:
	var raw_input := Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")

	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	# input = _camera_controller.global_transform.basis * input
	input.y = 0.0
	return input
	
func play_foot_step_sound() -> void:
	# _step_sound.pitch_scale = randfn(1.2, 0.2)
	# _step_sound.play()
	pass
	
func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)
