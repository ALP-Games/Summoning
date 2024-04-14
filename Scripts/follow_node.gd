class_name FollowNode extends Node

#@onready var owner: RigidBody3D
@onready var master: Player = get_parent()

# this needs to construct a grid of dudes

func remove_follower(minion: Minion) -> void:
	minion.unfollow()


func add_new_folower(minion: Minion) -> void:
	minion.make_follow(master)


func set_selection_visible(minion: Minion, visible:bool) -> void:
	minion.set_selection_visible(visible)
