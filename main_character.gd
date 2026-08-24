extends CharacterBody2D

@export var run_speed := 260.0
@export var acceleration := 1600.0
@export var deceleration := 2200.0
@export var jump_speed := 430.0
@export var gravity := 1200.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	var target_speed := direction * run_speed
	
	var rate := acceleration if direction != 0.0 else deceleration
	
	if is_on_floor() or (not is_on_floor() and direction != 0):
		velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	else:
		velocity.x = move_toward(velocity.x, target_speed, 0.2 * rate * delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed
	move_and_slide()
