# Global.gd
extends Node

var ui: Node
var game: Node
var menu: Node
var hud: Node
var screen_gameOver: Node
var player: Node

var screen_size = Vector2.ZERO

func _ready():
	screen_size = get_viewport().get_visible_rect().size

func explode(objType: String, spawnPos: Vector2):
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	explosion.global_position = spawnPos
	Global.game.get_node("Containers/Container_explosions").call_deferred("add_child", explosion)
	# Adjust explosion to fit differnt target .
	var sprite = explosion.get_node("AnimatedSprite2D")
	if objType == "bomb": sprite.scale = Vector2.ONE * 0.25
	elif objType == "player": sprite.scale = Vector2.ONE
	sprite.play("explode")

func reset_and_quit():
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
func control_db(action: String, section: String, key: String, value = 0):
	var config = ConfigFile.new()
	# C:\Users\maxwo\AppData\Roaming\Godot\app_userdata\A1_Space Invaders
	var path = "user://data.cfg"
	
	# Load existing data .
	if FileAccess.file_exists(path):
		var err = config.load(path)
		if err != OK:
			print("Error loading config:", err)
			return null
	
	match action:
		"get":
			return config.get_value(section, key, 0)
		"set":
			config.set_value(section, key, value)
		"add":
			var current = config.get_value(section, key, 0)
			config.set_value(section, key, current + value)
		"minus":
			var current = config.get_value(section, key, 0)
			config.set_value(section, key, current - value)
		
		_:
			print("Unknown action:", action)
			return null
	
	# Save changes if not a 'get' .
	if action != "get":
		var err = config.save(path)
		if err != OK:
			print("Error saving config:", err)
	
	return null

func control_nodeActiveStatus(node, action):
	if node == null: return
	
	var isEnable
	if action == "enable": isEnable = true
	elif action == "disable": isEnable = false
	else: return
	
	node.visible = isEnable
	node.set_process(isEnable)
	node.set_physics_process(isEnable)
	node.set_process_input(isEnable)
	
	if isEnable and node.has_method("reset"):
		node.reset()

func clamp_sprite_to_box(size_box: Vector2, pos_obj: Vector2, size_sprite: Vector2) -> Vector2:
	var halfSize_sprite = size_sprite / 2
	var x = clamp(pos_obj.x, halfSize_sprite.x, size_box.x - halfSize_sprite.x)
	var y = clamp(pos_obj.y, halfSize_sprite.y, size_box.y - halfSize_sprite.y)
	return Vector2(x, y)
