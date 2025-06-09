extends Node2D

@onready var Chek = $StaticBody2D/Chek
const mps = 800*5

func _process(delta: float) -> void:
	if Chek.is_colliding():
		set_process(false)
		var target = Chek.get_collider()
		var tm
		if target != null : tm = str(target.name)
		if tm != null : if tm[0] == "M" && tm[1] == "o" && tm[2] == "b" : if target != null : target.pv -= 1
		queue_free()
	var direction = Vector2(cos(rotation), sin(rotation))
	position += direction*mps*delta
	Chek.target_position.y = mps*delta*3
	if Chek.target_position.y < 30: Chek.target_position.y = 30
