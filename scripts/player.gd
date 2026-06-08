extends CharacterBody2D


const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const SPRING_JUMP_VELOCITY = -550.0
const INVULNERABILITY_DURATION := 1.0
const SPRING_FRAME_TRIGGER = 5

signal health_changed(new_health)

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_crouching := false
var health := 3
var is_invulnerable := false
var invulnerability_timer := 0.0
var is_spring_charging := false
var is_springing := false
var spring_charged := false


func _ready():
	health_changed.emit(health)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Crouch.
	is_crouching = is_on_floor() and Input.is_action_pressed("crouch")

	# Spring charge — al llegar al frame 6 se lanza solo
	if is_crouching:
		if not is_spring_charging:
			is_spring_charging = true
			animated_sprite_2d.play("crouch")
			animated_sprite_2d.frame = 0
		var current_frame = animated_sprite_2d.get_frame()
		if current_frame >= SPRING_FRAME_TRIGGER and not spring_charged:
			spring_charged = true
			_spring_launch()
	else:
		is_spring_charging = false
		spring_charged = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# Get the input direction (input_axis) and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if is_crouching:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif input_axis:
		velocity.x = input_axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Reset spring al aterrizar — debe ir DESPUÉS de move_and_slide
	if is_springing and is_on_floor():
		is_springing = false

	update_animations(input_axis)

	# Handle invulnerability.
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			animated_sprite_2d.modulate = Color.WHITE


func update_animations(input_axis):
	if is_springing:
		return
	if is_crouching:
		animated_sprite_2d.play("crouch")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("fall")
	else:
		if input_axis != 0:
			animated_sprite_2d.flip_h = input_axis < 0
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")


func take_damage(amount := 1):
	if is_invulnerable or health <= 0:
		return
	health -= amount
	health_changed.emit(health)
	is_invulnerable = true
	invulnerability_timer = INVULNERABILITY_DURATION
	animated_sprite_2d.modulate = Color(1, 0.3, 0.3)
	if health <= 0:
		die()


func die():
	GameManager.reset_score()
	call_deferred("_reload_scene")


func _reload_scene():
	get_tree().reload_current_scene()


func _spring_launch():
	velocity.y = SPRING_JUMP_VELOCITY
	velocity.x = (-1 if animated_sprite_2d.flip_h else 1) * SPEED * 0.5
	is_springing = true
	is_spring_charging = false
	spring_charged = false
	is_crouching = false
	
	is_invulnerable = true
	invulnerability_timer = INVULNERABILITY_DURATION


func _is_above_enemy(enemy) -> bool:
	return global_position.y < enemy.global_position.y


func _stomp_enemy(enemy):
	enemy.queue_free()
	velocity.y = JUMP_VELOCITY * 0.6
	is_springing = false
	GameManager.add_score(1)


func _on_enemy_detector_body_entered(body):
	if is_springing and _is_above_enemy(body):
		_stomp_enemy(body)
	else:
		take_damage()


func _on_enemy_detector_area_entered(area):
	if is_springing and _is_above_enemy(area):
		_stomp_enemy(area)
	else:
		take_damage()
