extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D

func _ready():
	add_to_group("enemies")

func _on_hitbox_area_entered(area: Area2D) -> void:
	animated_sprite.play("dies")
	await get_tree().create_timer(0.5).timeout
	queue_free()
