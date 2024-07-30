class_name Enemy
extends CharacterBody3D

@export var player: Player

@onready var animationPlayer = $model/AnimationPlayer

var alive = true

const KNOCKBACK_FORCE = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("gun_idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not alive:
		if velocity.length_squared() >= 1:
			velocity += Vector3.FORWARD * KNOCKBACK_FORCE * delta
			self.move_and_slide()

func try_kill():
	if alive:
		set_collision_layer_value(CollisionLayer.ENEMY_BODY, false)
		$RayCast3D.enabled = false
		$RayCast3D.visible = false
		alive = false
		animationPlayer.play("dead2")
		velocity = Vector3.BACK * KNOCKBACK_FORCE
		$DeathCry.play()
		return true
