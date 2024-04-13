class_name FollowNode extends Node

#@onready var owner: RigidBody3D
@onready var master: RigidBody3D = get_parent()

# this needs to construct a grid of dudes

func remove_follower(minion: Minion) -> void:
	minion.set_follow_node(null)
	minion._state = minion.State.STAY


func add_new_folower(minion: Minion) -> void:
	minion.set_follow_node(self)
	minion.get_close_to_master(master)

func set_selection_visible(minion: Minion, visible:bool) -> void:
	minion.set_selection_visible(visible)
