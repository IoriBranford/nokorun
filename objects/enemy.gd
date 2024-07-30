class_name Enemy
extends CharacterBody3D

@export var player: Player

@onready var animationPlayer = $model/AnimationPlayer

var alive = true

const KNOCKBACK_FORCE = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("gun_idle")

func update_sight():
	if $RayCast3D.is_colliding():
		var dist = $RayCast3D.global_position.distance_to($RayCast3D.get_collision_point())
		$RayCast3D/LaserSight.scale.z = dist / $RayCast3D.scale.z
	else:
		$RayCast3D/LaserSight.scale.z = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if alive:
		update_sight()
		if player:
			look_at(player.global_position, Vector3.UP, true)
	else:
		if velocity.length_squared() >= 1:
			velocity += Vector3.FORWARD * KNOCKBACK_FORCE * delta
			self.move_and_slide()

func try_kill():
	if alive:
		look_at(global_position + Vector3.FORWARD, Vector3.UP, true)
		set_collision_layer_value(CollisionLayer.ENEMY_BODY, false)
		$RayCast3D.enabled = false
		$RayCast3D.visible = false
		alive = false
		animationPlayer.play("dead2")
		velocity = Vector3.BACK * KNOCKBACK_FORCE
		$DeathCry.play()
		return true
