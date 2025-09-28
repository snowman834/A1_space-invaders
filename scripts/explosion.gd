extends Area2D

func _ready():
	pass
	
func _physics_process(delta):
	pass

func _on_animated_sprite_2d_animation_finished():
	queue_free()
