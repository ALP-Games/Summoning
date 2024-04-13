class_name Building extends StaticBody3D

@export var health_component: HealthComponent = null
@export var faction: Factions.Names = Factions.Names.UNDEAD

var init_called: bool = false

func _ready() -> void:
	init()


func init() -> void:
	init_called = true
	if health_component:
		health_component.health_owner = self


func deal_damage(damage: float) -> void:
	assert(init_called, "Iinit was not called")
	if health_component:
		health_component.deal_damage(damage)
