class_name Character extends RigidBody3D

@export var health_component: HealthComponent = null
@export var attack_component: AttackComponent = null
@export var faction: Factions.Names = Factions.Names.UNDEAD

var init_called: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()


func init() -> void:
	init_called = true
	if health_component:
		health_component.health_owner = self


func deal_damage(dealt_damage:float) -> void:
	assert(init_called, "Init was not called")
	if health_component:
		health_component.deal_damage(dealt_damage)
