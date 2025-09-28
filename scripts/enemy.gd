class_name Enemy extends Area2D

@export var enemy_type := "bomber"
@export var speed_move = 150.0
@export var hp := 3
@export var chance_dropBomb := 0.01

var isVisible = false
var isBombDrop = false
var posY_dropBomb = 0.0

func _ready():
	posY_dropBomb = randi_range(0, Global.screen_size.y/2)
	
func _physics_process(delta):
	move(delta)
	drop_bomb()

func move(delta):
	global_position.y += speed_move * delta

func drop_bomb():
	if isBombDrop || is_in_group("enemies_2"): return
	
	if global_position.y >= posY_dropBomb:
		isBombDrop = true
		var bomb = preload("res://scenes/bomb.tscn").instantiate()
		bomb.chosen_bomb_type = 1
		bomb.global_position = global_position # Bomb spawn position
		Global.game.get_node("Containers/Container_bombs").add_child(bomb)

func _on_visible_on_screen_notifier_2d_screen_entered():
	isVisible = true
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	if isVisible: 
		queue_free()
		Global.game.game_end()

func _on_body_entered(body: Node2D):
	if body is Player && Global.game.isGameStart:
		body.take_damage(1)
		Global.game.get_node("SFX/Sound_explode").play()
		Global.explode(enemy_type, global_position)
		queue_free()
	
func take_damage(val_damage):
	hp -= val_damage
	if hp == 0:
		if Global.game.isGameStart:
			Global.ui.control_score("add", 1)
		queue_free()
		Global.game.get_node("SFX/Sound_explode").play()
		Global.explode(enemy_type, global_position)
	else:
		Global.game.get_node("SFX/Sound_hit").play()
