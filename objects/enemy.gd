class_name Enemy
extends Node3D

@onready var animationPlayer = $model/AnimationPlayer

var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("gun_idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func try_kill():
	if alive:
		alive = false
		animationPlayer.play("dead2")
		return true
