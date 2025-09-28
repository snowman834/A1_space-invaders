extends Area2D

@export var chosen_bomb_type := 1

# Define bomb types in a dictionary .
@export var bomb_types = {
	1: { "scale": 0.3,  "radius": 13, "speed": 300 },
	2: { "scale": 0.14, "radius": 6,  "speed": 300 },
	3: { "scale": 1, "radius": 45,  "speed": 10 }
}

var hp := 1
var speed_fall := 0

func _ready():
	setup_bomb(chosen_bomb_type)

func setup_bomb(cmd):
	var bomb = bomb_types[cmd]
	$Sprite2D.scale = Vector2.ONE * bomb.scale
	$CollisionShape2D.shape.radius = bomb.radius
	speed_fall = bomb.speed
	
func _physics_process(delta):
	move(delta)

func move(delta):
	global_position.y += speed_fall * delta
	
func _on_body_entered(body: Node2D):
	if body is Player && Global.game.isGameStart:
		body.take_damage(1)
		Global.game.get_node("SFX/Sound_explode").play()
		Global.explode("bomb", global_position)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func take_damage(val_damage):
	Global.game.get_node("SFX/Sound_explode").play()
	Global.explode("bomb", global_position)
	queue_free()
