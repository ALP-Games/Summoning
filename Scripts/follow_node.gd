class_name FollowNode extends Node

#@onready var owner: RigidBody3D
@onready var master: RigidBody3D = get_parent()

# this needs to construct a grid of dudes


func add_new_folower(minion: Minion) -> void:
	minion.set_follow_node(self)
	minion.get_close_to_master(master)
