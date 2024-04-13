class_name HealthComponent extends Node

@export var max_hp: float = 100.0

@onready var current_hp := max_hp

var health_owner: Node3D = null

func deal_damage(damage: float) -> void:
	current_hp -= damage
	if current_hp <= 0:
		health_owner.queue_free()
