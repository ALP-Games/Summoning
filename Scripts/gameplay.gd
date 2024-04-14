class_name Gameplay extends Node3D

@export var spirit_well: SpiritWell = null
@export var player: Player = null
@export var entities: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.gameplay = self


func load_game_over() -> void:
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
