class_name Player
extends CharacterBody3D

signal coin_collected
signal enemy_killed

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 1000
@export var jump_strength = 10
@export var autorun = false

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0
var leftHornLevel = 1
var rightHornLevel = 1

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var animation = $Model/AnimationPlayer
@onready var leftHorn = $Model/Rig/Skeleton3D/LeftHornAttachment
@onready var rightHorn = $Model/Rig/Skeleton3D/RightHornAttachment

const HORN_HITBOX_BASE_HEIGHT = 1
const HORN_HITBOX_GROW_HEIGHT = .5
const HORN_MODEL_BASE_SCALE = 3
const HORN_MODEL_GROW_SCALE = 1.5

# Functions

func set_horn_level(horn: Node3D, level: int):
	var model = horn.get_node("Model")
	model.scale.x = HORN_MODEL_BASE_SCALE + level*HORN_MODEL_GROW_SCALE
	var hitbox = horn.get_node("Hitbox")
	var shape: CollisionShape3D = hitbox.get_node("CollisionShape3D")
	var cylinder = shape.shape
	if cylinder is CylinderShape3D:
		cylinder.height = HORN_HITBOX_BASE_HEIGHT + level*HORN_HITBOX_GROW_HEIGHT
		hitbox.position.y = cylinder.height / 2

func horn_body_entered(body):
	if body is Enemy:
		if body.try_kill():
			enemy_killed.emit(body)
			Audio.play("res://sounds/cut_sounds.tres")

func _ready():
	for horn in [leftHorn, rightHorn]:
		var hitbox = horn.get_node("Hitbox")
		hitbox.connect("body_entered", horn_body_entered)
	set_horn_level(leftHorn, leftHornLevel)
	set_horn_level(rightHorn, rightHornLevel)

func _physics_process(delta):
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
	# Movement

	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	
	if position.y < -10:
		get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	
	# model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	# Animation when landing
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		# model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects():
	
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation.play("Normal Running", 0.5)
			particles_trail.emitting = true
			sound_footsteps.stream_paused = false
		else:
			animation.play("Standing 2", 0.5)
	else:
		animation.play("Jumping Forward Still", 0.5)

# Handle movement input

func handle_controls(delta):
	
	# Movement
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = -1.0 if autorun else Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * movement_speed * delta
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("res://sounds/jump.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			
			jump_double = false
			# model.scale = Vector3(0.5, 1.5, 0.5)
			
		if(jump_single): jump()

# Handle gravity

func handle_gravity(delta):
	
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func jump():
	
	gravity = -jump_strength
	
	# model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false;
	jump_double = true;

# Collecting coins

func collect_coin():
	
	coins += 1
	
	coin_collected.emit(coins)

	$SoundEat.play()
