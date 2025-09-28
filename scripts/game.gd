extends Node2D

@export var speed_enemySpawn = 0.01
@export var speed_scroll = 100

var sceneContainer_enemies: Array[PackedScene] = []

var isGameStart = false
	
func _ready():
	Global.game = self
	
	# Enemy setup
	var enemy_1 = preload("res://scenes/enemy.tscn")
	var enemy_2 = preload("res://scenes/enemy_2.tscn")
	sceneContainer_enemies.append(enemy_1)
	sceneContainer_enemies.append(enemy_2)

func _process(delta):
	Global.reset_and_quit()
	bg_move(delta)

func bg_move(delta):
	if $ParallaxBackground.scroll_offset.y >= 960:
		$ParallaxBackground.scroll_offset.y = 0
	$ParallaxBackground.scroll_offset.y += speed_scroll * delta
	
func _on_timer_enemy_spawn_timeout():
	# Increase spawn speed .
	$Timer_enemySpawn.wait_time = max($Timer_enemySpawn.wait_time - speed_enemySpawn, 0.5)
	var enemy = sceneContainer_enemies.pick_random().instantiate()
	# Ensure enemies not clip by screen .
	var halfSize_enemy = enemy.get_node("Sprite2D").texture.get_size()/2
	var spawnX = randf_range(0 + halfSize_enemy.x, Global.screen_size.x - halfSize_enemy.x)
	var spawnY = 0 - halfSize_enemy.y
	enemy.global_position = Vector2(spawnX, spawnY)
	$Containers/Container_enemies.add_child(enemy)

func game_start():
	isGameStart = true
	
	# Clean previous leftover lasers and enemies if start game too quick .
	for child in $Containers/Container_lasers.get_children(): child.queue_free()
	for child in $Containers/Container_enemies.get_children(): child.queue_free()
	for child in $Containers/Container_bombs.get_children(): child.queue_free()
	for child in $Containers/Container_explosions.get_children(): child.queue_free()
	
	$Particles_star.emitting = true
	Global.player.show()
	Global.player.control_hp("set", 3)
	Global.player.global_position = $Pos_playerSpawn.global_position
	$Timer_enemySpawn.start()

func game_end():
	if (isGameStart == false): return # Prevent multi-trigger many enemies touch ground .
	isGameStart = false
	$Particles_star.emitting = false
	Global.ui.get_node("HUD").visible = false
	$Timer_enemySpawn.stop()
	await get_tree().create_timer(3).timeout
	Global.ui.get_node("Menu_gameOver").visible = true
	Global.ui.show_result()
