extends Area2D

@export var speed = 600

func _ready():
	pass

func _physics_process(delta):
	move(delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies") || area.is_in_group("bombs"):
		area.take_damage(1)
		queue_free()

func move(delta):
	global_position.y += speed * -1 * delta
