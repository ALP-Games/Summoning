class_name SummonResource extends Resource

@export var summoned_creature: PackedScene = null
@export var blue_souls: int = 10
@export var red_souls: int = 0


func summon_at(summoner: Player, position: Vector3) -> bool:
	var enough_blue = summoner.resources.has_enough(Souls.Type.BLUE, blue_souls)
	var enough_red = summoner.resources.has_enough(Souls.Type.RED, red_souls)
	if not enough_blue or not enough_red:
		return false
	summoner.resources.remove_souls(Souls.Type.BLUE, blue_souls)
	summoner.resources.remove_souls(Souls.Type.RED, red_souls)
	var creature_instance := summoned_creature.instantiate() as Node3D
	game_manager.gameplay.entities.add_child(creature_instance)
	creature_instance.global_position = position
	return true
