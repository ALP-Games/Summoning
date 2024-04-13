class_name AttackHitbox extends Area3D

func _ready() -> void:
	monitoring = false


func attack() -> void:
	monitoring = true


func stop() -> void:
	monitoring = false
