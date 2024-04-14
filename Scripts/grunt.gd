class_name Grunt extends Character

@export var speed: float = 9.5
@export var path_calc_time: float = 0.1
@export var distance_to_enemy: float = 1.0
@export var model: Node3D = null

@onready var x_scale = model.scale.x
@onready var attack_range: Area3D = $AttackRange
@onready var aggro_range: Area3D = $AggroRange

var elapsed_time: float = 0
var anim_player: AnimationPlayer = null

@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

enum State {
	IDLE,
	GOING_TO_TARGET,
	ATTACKING
}
var _state: State = State.IDLE
var _target: Node3D = null
var _move_direction: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()
	for child in model.get_children():
		if child is AnimationPlayer:
			anim_player = child
	_navigation_agent.target_desired_distance = distance_to_enemy
	_navigation_agent.path_desired_distance = 1.0
	if _target:
		_navigation_agent.target_position = _target.global_position
	attack_range.body_entered.connect(attack_range_entered)
	attack_range.monitoring = true
	aggro_range.body_entered.connect(aggro_range_entered)


func _physics_process(delta: float) -> void:
	if _state == State.IDLE:
		pass
	elif _state == State.GOING_TO_TARGET:
		_process_going_to_target(delta)
	elif _state == State.ATTACKING:
		_process_attack(delta)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = _move_direction * speed
	if _move_direction.length() == 0 and _state == State.IDLE:
		anim_player.play("Idle")
	else:
		anim_player.play("Walk")
	if _move_direction.x != 0:
		model.scale.x = x_scale * sign(_move_direction.x)


func _process_going_to_target(delta: float) -> void:
	if not _navigation_agent.is_navigation_finished():
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		_move_direction = direction.normalized()
	else:
		_move_direction = Vector3.ZERO
		_state = State.ATTACKING
		pass


func _process_attack(delta: float) -> void:
	if attack_component.can_attack():
		for body in attack_range.get_overlapping_bodies():
			if body == _target:
				anim_player.play("Attack")
				var attack_direction = global_position.direction_to(_target.global_position)
				attack_component.start_attack(attack_direction)
	elif _target != null:
		set_target(_target)
		attack_range.monitoring = true


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time:
		elapsed_time -= path_calc_time
		if not _target:
			return
		_navigation_agent.target_position = _target.global_position


func set_target(target: Node3D) -> void:
	elapsed_time = 0
	disconnect_signal_from_target()
	_target = target
	_state = State.GOING_TO_TARGET
	if _navigation_agent:
		_navigation_agent.target_position = _target.global_position


func disconnect_signal_from_target() -> void:
	if not _target:
		return
	if _target is Character:
		var other_char := _target as Character
		other_char.dying.disconnect(target_died)
	elif _target is Building:
		var building := _target as Building
		building.dying.disconnect(target_died)


func connect_signal_to_target() -> void:
	if not _target:
		return
	if _target is Character:
		var other_char := _target as Character
		other_char.dying.connect(target_died)
	elif _target is Building:
		var building := _target as Building
		building.dying.connect(target_died)


func target_died(target: Node3D) -> void:
	_state = State.IDLE
	_target = null


func attack_range_entered(body: Node3D) -> void:
	if body == _target:
		if _state == State.GOING_TO_TARGET:
			_state = State.ATTACKING
			attack_range.monitoring = false
		elif _state == State.ATTACKING:
			pass


func aggro_range_entered(body: Node3D) -> void:
	if not _target or global_position.distance_to(body.global_position) < \
	global_position.distance_to(_target.global_position):
		set_target(body)
