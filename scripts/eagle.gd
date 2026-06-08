extends Area2D

const SPEED = 30.0

var direction := 1

@onready var animated_sprite_2d = $AnimatedSprite2D


func _physics_process(delta):
	position.x += direction * SPEED * delta


func _on_timer_timeout():
	direction *= -1
	animated_sprite_2d.flip_h = direction < 0
