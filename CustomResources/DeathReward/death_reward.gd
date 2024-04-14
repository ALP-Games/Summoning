class_name DeathReward extends Resource

@export var blue_souls_amount: int = 10
@export var red_souls_amount: int = 0

func pay_out() -> void:
	game_manager.gameplay.player.resources.add_souls(Souls.Type.BLUE, blue_souls_amount)
	game_manager.gameplay.player.resources.add_souls(Souls.Type.RED, red_souls_amount)
