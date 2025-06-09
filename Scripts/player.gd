extends CharacterBody2D

@export var BulletPath : PackedScene
var SPEED := 300.0
var JUMP_VELOCITY := -400.0
var pv = 10

func _process(delta: float) -> void:
	if not get_parent().GameProcessing:
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"): get_parent().CreateNode(BulletPath, position.x, position.y, rotation)
	move_and_slide()
	if position.y <= -64 or position.y >= get_viewport().size.y+64 : pv = 0 ; set_physics_process(false)
