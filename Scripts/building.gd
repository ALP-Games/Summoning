class_name Building extends StaticBody3D

signal dying(building: Building)

@export var health_component: HealthComponent = null
@export var faction: Factions.Names = Factions.Names.UNDEAD

var init_called: bool = false

func _ready() -> void:
	init()


func init() -> void:
	init_called = true
	if health_component:
		health_component.health_owner = self
		health_component.destroy.connect(die)


func deal_damage(damage: float) -> void:
	assert(init_called, "Iinit was not called")
	if health_component:
		health_component.deal_damage(damage)


func die() -> void:
	dying.emit(self)
	queue_free()
