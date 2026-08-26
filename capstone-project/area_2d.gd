extends Area2D
class_name Bullet

var speed = 250

func _physics_process(delta):
	position += transform.x * speed * delta
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		print("enemyhit")
	queue_free()
