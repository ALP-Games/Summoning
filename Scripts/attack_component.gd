class_name AttackComponent extends Node

@export var damage_hitbox: AttackHitbox = null
@export var attack_interval: float = 0.5
@export var attack_length: float = 0.2
@export var attack_delay: float = 0.0
@export var damage: float = 1.0

@onready var character: Character = get_parent()

var _cooldown: float = 0.0
var _delay_elapsed: float = 0.0
var _attack_elapsed: float = 0.0
var hit_entities: Array[Node3D]

enum State {
	READY,
	DELAY,
	ATTACKING,
	ON_COOLDOWN
}
var attack_state: State = State.READY

func _ready() -> void:
	damage_hitbox.body_entered.connect(attack_collision_entered)


func can_attack() -> bool:
	return attack_state == State.READY


func start_attack(offset: Vector3) -> void:
	if attack_state != State.READY:
		return
	attack_state = State.DELAY
	hit_entities = []
	damage_hitbox.position = offset
	_delay_elapsed = 0.0


func _process(delta: float) -> void:
	if attack_state == State.DELAY:
		_process_delay(delta)
	elif attack_state == State.ATTACKING:
		_process_attacking(delta)
	elif attack_state == State.ON_COOLDOWN:
		_process_on_cooldown(delta)


func _process_on_cooldown(delta: float) -> void:
	_cooldown -= delta
	if _cooldown <= 0.0:
		attack_state = State.READY


func _process_attacking(delta: float) -> void:
	_attack_elapsed += delta
	if _attack_elapsed >= attack_length:
		attack_state = State.ON_COOLDOWN
		_cooldown = attack_interval
		damage_hitbox.stop()


func _process_delay(delta: float) -> void:
	_delay_elapsed += delta
	if _delay_elapsed >= attack_delay:
		attack_state = State.ATTACKING
		damage_hitbox.attack()
		_attack_elapsed = 0.0


func attack_collision_entered(body: Node3D) -> void:
	if hit_entities.find(body) != -1:
		return
	if body is Building:
		var building := body as Building
		if building.faction != character.faction:
			hit_entities.append(building)
			building.deal_damage(damage)
	elif body is Character:
		var other_character := body as Character
		if other_character.faction != character.faction:
			hit_entities.append(other_character)
			other_character.deal_damage(damage)
