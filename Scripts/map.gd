extends Node2D

@export var PlayerPath : PackedScene
@export var MobPath : PackedScene
@onready var camera = $Vision
@onready var _lines = $Lines
@onready var _collisions = _lines.get_node("LinesColisions")
@onready var ScoreText = $HUD/Score_text
@onready var life_text = $HUD/life
var player : Node
var _pressed : bool = false
var _current_line : Line2D
var _current_line_shape : CollisionPolygon2D
var GameProcessing : bool = true
var SpawnMobDelta : float = 5.0
var lines_array : Array
var lines_collisions_array : Array
var current_point : Vector2
var initial_point : Vector2
var time : float = 0.0
var LineTimeout : bool = false
var TimerIndex : int = 0
var drawing : bool = false

func _ready() -> void:
	_start_game()

func _process(delta: float) -> void:
	if GameProcessing:
		time += delta
		if time > delta:
			camera.position.x = player.position.x
			camera.position.y = get_viewport().size.y/2
			ScoreText.position = camera.position-Vector2(get_viewport().size)/2
			ScoreText.custom_minimum_size.x = get_viewport().size.x
			ScoreText.text = str(int(player.position.x)-576)
			life_text.position = Vector2(3,34)+(camera.position-Vector2(get_viewport().size)/2)
			life_text.text = str(player.pv)
			var marge = 250
			$Walls/floor.position = Vector2(get_viewport().size.x/2+camera.position.x-get_viewport().size.x/2, get_viewport().size.y+camera.position.y-get_viewport().size.y/2+marge)
			$Walls/ceil.position = Vector2(get_viewport().size.x/2+camera.position.x-get_viewport().size.x/2, camera.position.y-get_viewport().size.y/2-marge)
			$Walls/left.position = Vector2(camera.position.x-get_viewport().size.x/2-marge, get_viewport().size.y/2+camera.position.y-get_viewport().size.y/2)
			$Walls/right.position = Vector2(get_viewport().size.x+camera.position.x-get_viewport().size.x/2+marge, get_viewport().size.y/2+camera.position.y-get_viewport().size.y/2)
			$Walls/floor.shape.size = Vector2(get_viewport().size.x*2+1000,0)
			$Walls/ceil.shape.size = Vector2(get_viewport().size.x*2+1000,0)
			$Walls/left.shape.size = Vector2(0,get_viewport().size.y*2+1000)
			$Walls/right.shape.size = Vector2(0,get_viewport().size.y*2+1000)
	else : _pressed = false ; time = 0.0

func CreateNode(node, x, y, rota):
	node = node.instantiate()
	node.position = Vector2(x, y)
	node.rotation = rota
	add_child(node)

func CreateMob(x, y, rota):
	var Mob = MobPath.instantiate()
	Mob.position = Vector2(x, y)
	Mob.rotation = rota
	add_child(Mob)

func _input(event: InputEvent) -> void:
	#if (LineTimeout && _current_line != null):
	#	_pressed = false
	if event is InputEventMouseButton:
		if _pressed && not event.pressed : hide_line(_current_line)
		_pressed = event.pressed
		if _pressed && not Input.is_action_pressed("shoot"):
			drawing = true
			_current_line = Line2D.new()
			line_timer()
			current_point = event.position+Vector2(camera.position.x-get_viewport().size.x/2, 0)
			initial_point = current_point
			_lines.add_child(_current_line)
			lines_array.append(_current_line)
			line_collision(event.position+Vector2(camera.position.x-get_viewport().size.x/2, 0))
		else : _pressed = false
	
	if event is InputEventMouseMotion && _pressed && drawing:
		line_collision(event.position+Vector2(camera.position.x-get_viewport().size.x/2, 0))
		_current_line.add_point(event.position+Vector2(camera.position.x-get_viewport().size.x/2, 0))
		if initial_point.distance_to(current_point) > 750 : drawing = false 

func line_timer(index : int = TimerIndex+1):
	LineTimeout = false
	TimerIndex += 1
	await get_tree().create_timer(2).timeout
	if TimerIndex == index : LineTimeout = true

func line_collision(pos : Vector2):
	_current_line_shape = CollisionPolygon2D.new()
	_current_line_shape.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	_current_line_shape.polygon = PackedVector2Array([current_point, current_point, pos])
	_collisions.add_child(_current_line_shape)
	current_point = pos
	lines_collisions_array.append(_current_line_shape)

func hide_line(line : Line2D):
	await get_tree().create_timer(.1).timeout
	while not _pressed:
		await get_tree().create_timer(.001).timeout
	if line != null:
		line.queue_free()
		lines_array.remove_at(lines_array.find(line))
	for collision in lines_collisions_array:
		collision.queue_free()
	lines_collisions_array.clear()

func _start_game():
	CreateNode(PlayerPath, $BaseGround.position.x, $BaseGround.position.y, 0)
	player = get_node("Player")
	GameProcessing = true
	while GameProcessing:
		var x
		var y
		if randf()<.5:
			x = randf_range(0, get_viewport().size.x)
			if randf()<.5 : y = 0
			else : y = get_viewport().size.y
		else :
			y = randf_range(0, get_viewport().size.y)
			if randf()<.5 : x = 0
			else : x = get_viewport().size.x
		x += camera.position.x-get_viewport().size.x/2
		y += camera.position.y-get_viewport().size.y/2
		CreateMob(x, y, 0)
		var wait = 0
		while wait < SpawnMobDelta && GameProcessing:
			await get_tree().create_timer(.01).timeout
			wait += .01
			if player.pv <= 0 : GameProcessing = false
		SpawnMobDelta -= .2
		if SpawnMobDelta < 1 : SpawnMobDelta = 1
	await get_tree().create_timer(.01).timeout
	RestartGame()

func RestartGame():
	ResetNodes()
	get_tree().create_timer(0.01)
	delete_datas()
	get_tree().create_timer(0.01)
	_start_game()

func delete_datas():
	SpawnMobDelta = 5.0
	player = null
	_current_line = null
	_current_line_shape = null
	_pressed = false
	lines_array.clear()
	lines_collisions_array.clear()
	current_point = Vector2.ZERO

func ResetNodes():
	camera.position = Vector2(575, 325)
	for lines in lines_array:
		lines.queue_free()
	for collisions in lines_collisions_array:
		collisions.queue_free()
