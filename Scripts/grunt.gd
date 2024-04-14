class_name Grunt extends Character

@export var speed: float = 9.5
@export var path_calc_time: float = 0.1
@export var distance_to_enemy: float = 1.0
@export var model: Node3D = null
@export var death_reward: DeathReward = null

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
var _aggro_targets: Array[Node3D]

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
	aggro_range.body_entered.connect(aggro_range_entered)
	aggro_range.body_exited.connect(aggro_range_left)


func _physics_process(delta: float) -> void:
	if _state == State.IDLE:
		pass
	elif _state == State.GOING_TO_TARGET:
		_process_going_to_target(delta)
	elif _state == State.ATTACKING:
		_process_attack(delta)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = _move_direction * speed
	if _move_direction.length() == 0 and _state != State.ATTACKING:
		anim_player.play("Idle")
	elif _state == State.GOING_TO_TARGET:
		anim_player.play("Walk")
	if _move_direction.x != 0:
		model.scale.x = x_scale * sign(_move_direction.x)


func _process_going_to_target(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time:
		elapsed_time -= path_calc_time
		if not _target:
			return
		_navigation_agent.target_position = _target.global_position
	
	if not _navigation_agent.is_navigation_finished():
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		_move_direction = direction.normalized()
	else:
		_move_direction = Vector3.ZERO
		_state = State.ATTACKING
		pass


func _process_attack(_delta: float) -> void:
	if attack_component.can_attack():
		attack_range.monitoring = true
		for body in attack_range.get_overlapping_bodies():
			if body == _target:
				anim_player.play("Attack")
				var attack_direction = global_position.direction_to(_target.global_position)
				attack_component.start_attack(attack_direction)
	elif _target != null and not attack_component.is_attacking():
		set_target(_target)
		attack_range.monitoring = true
	


func set_target(target: Node3D) -> void:
	elapsed_time = 0
	disconnect_signal_from_target()
	_target = target
	connect_signal_to_target()
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


func target_died(_target: Node3D) -> void:
	if not find_and_set_closet_target():
		# need to set well as target
		_state = State.IDLE


func attack_range_entered(body: Node3D) -> void:
	if body == _target:
		if _state == State.GOING_TO_TARGET:
			_state = State.ATTACKING
			_move_direction = Vector3.ZERO
			attack_range.set_deferred("monitoring", false)
		elif _state == State.ATTACKING:
			pass


func aggro_range_entered(body: Node3D) -> void:
	_aggro_targets.append(body)
	find_and_set_closet_target()


func aggro_range_left(body: Node3D) -> void:
	_aggro_targets.erase(body)
	if _target == body:
		find_and_set_closet_target()


func find_and_set_closet_target() -> bool:
	var new_target: Node3D = null
	var shortest_dist: float = 1000000000000.0
	for target in _aggro_targets:
		var cur_dist := global_position.distance_to(target.global_position)
		if (new_target and target is Character and \
		(new_target is Building or new_target is Player)) or \
		(cur_dist < shortest_dist):
			new_target = target
			shortest_dist = cur_dist
	if new_target:
		set_target(new_target)
		return true
	else:
		_target = game_manager.gameplay.spirit_well
		return false


func die() -> void:
	death_reward.pay_out()
	super()
