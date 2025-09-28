class_name Player extends CharacterBody2D

@export var speed_move = 300
@export var cd_shoot = 0.25
@export var time_shieldValid := 5.0
@export var time_shieldCd := 5.0

var scene_laser = preload("res://scenes/laser.tscn")
var hp := 3
var canShoot = true
var isInvincible = false
var canGetShield = true

func _ready():
	Global.player = self
	
func _physics_process(delta):
	move()
	shoot()
	get_shield()
	
func _process(delta):
	pass
	
func move():
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	velocity = direction * speed_move
	move_and_slide()
	global_position = Global.clamp_sprite_to_box(Global.screen_size, global_position, $Sprite2D.texture.get_size())
	
func shoot():
	if Input.is_action_pressed("shoot") && canShoot:
		canShoot = false
		
		var laser = scene_laser.instantiate()
		laser.global_position = $Muzzle.global_position
		Global.game.get_node("Containers/Container_lasers").add_child(laser)
		Global.game.get_node("SFX/Sound_laser").play()
		
		# Set shoot CD .
		await get_tree().create_timer(0.25).timeout
		canShoot = true

func get_shield():
	if Input.is_action_pressed("shield") && canGetShield:
		# Shield valid time .
		canGetShield = false
		isInvincible = true
		Global.ui.get_node("HUD/TRect_shield").modulate.a = 0 # Make it invisible .
		$Anim_shield.visible = true
		
		# Shield times up .
		await get_tree().create_timer(time_shieldValid).timeout
		isInvincible = false
		$Anim_shield.visible = false
		
		# Shield enters CD .
		await get_tree().create_timer(time_shieldCd).timeout
		canGetShield = true
		Global.ui.get_node("HUD/TRect_shield").modulate.a = 1 # Make it visible .

func control_hp(action, value=0):
	var box_hps = Global.ui.get_node("HUD/HBox_HPs")
	var count_hp := 0
	for child in box_hps.get_children():
		if child.visible:
			count_hp += 1
	
	match (action):
		("get"):
			return count_hp
		("set"):
			count_hp = value
		("add"):
			count_hp += value
		("minus"):
			count_hp -= value
			
	count_hp = clamp(count_hp, 0, 3)
	
	for i in range(3):
		var rect_hp = box_hps.get_child(i)
		if i < count_hp:
			rect_hp.visible = true
		else:
			rect_hp.visible = false

func take_damage(val_damage):
	if isInvincible: Global.ui.control_score("add", 1)
	else: control_hp("minus", val_damage)
	
	var count_hp = control_hp("get")
	if count_hp == 0: 
		Global.explode("player", global_position)
		Global.game.get_node("SFX/Sound_explode").play()
		hide()
		Global.game.game_end()
	else:
		Global.game.get_node("SFX/Sound_hit").play()	
