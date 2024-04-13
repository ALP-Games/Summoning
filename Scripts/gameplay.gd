class_name Gameplay extends Node3D

@export var spirit_well: SpiritWell = null
@export var entities: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.gameplay = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
