extends CharacterBody2D

var SPEED = 5
var pv = 3
@onready var chek = $Chek
var Player : Node
var CameraPosition : Vector2
var MobPath : PackedScene

func _process(delta: float) -> void:
	if not get_parent().GameProcessing : queue_free()
	elif pv == 0 : queue_free()
	elif pv == 1 : self.modulate = Color(255, 0, 0)
	elif pv == 2 : self.modulate = Color(255, 255, 0)
	else : self.modulate = Color(0, 255, 0)

func _physics_process(delta: float) -> void:
	name = "Mob"
	MobPath = get_parent().MobPath
	Player = get_parent().get_node("Player")
	CameraPosition = get_parent().get_node("Vision").position
	if chek.is_colliding():
		for collision in chek.collision_result:
			collision = collision.collider
			if collision != null : if collision.name == "Player":
				collision.pv -= 1
				queue_free()
	var posp := Vector2(0,0)
	if get_parent().get_node("Player") != null : posp = get_parent().get_node("Player").position
	var Direction = (posp-position).normalized()
	velocity += Direction*SPEED
	look_at(posp)
	move_and_slide()
