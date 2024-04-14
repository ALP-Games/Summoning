class_name Minion extends Character

@export var speed: float = 9.5
@export var path_calc_time: float = 0.1
@export var move_with_master_distance: float = 2.0
@export var max_distance_from_master: float = 10.0
@export var max_distance_from_stay: float = 7.0
@export var model: Node3D = null
@export var selection: Node3D = null
@onready var x_scale = model.scale.x

var elapsed_time: float = 0
var anim_player: AnimationPlayer = null

@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _stay_pos: Vector3 = global_position
@onready var attack_range: Area3D = $AttackRange
@onready var aggro_range: Area3D = $AggroRange

enum CommandState {
	FOLLOWING,
	STAYING
}
enum State {
	GET_CLOSE_TO_MASTER,
	WALK_WTIH_MASTER,
	STAY,
	GOING_TO_ATTACK_TARGET,
	ATTACKING
}
var _command_state: CommandState = CommandState.STAYING
var _state: State = State.STAY
var _current_master: RigidBody3D = null
var _follow_node: FollowNode = null
var _attack_target: Node3D = null
var _move_direction: Vector3
var _aggro_targets: Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()
	_navigation_agent.target_desired_distance = 1.5
	_navigation_agent.path_desired_distance = 1.0
	selection.hide()
	for child in model.get_children():
		if child is AnimationPlayer:
			anim_player = child
	attack_range.body_entered.connect(attack_range_entered)
	aggro_range.body_entered.connect(aggro_range_entered)
	aggro_range.body_exited.connect(aggro_range_left)
	anim_player.play("Walk")


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = _move_direction * speed
	var dir := sign(_move_direction.x) as int
	if dir:
		model.scale.x = x_scale * dir


func _physics_process(delta: float) -> void:
	if _state == State.GET_CLOSE_TO_MASTER:
		_process_get_close_to_master(delta)
	elif _state == State.WALK_WTIH_MASTER:
		_process_move_with_master(delta)
	elif _state == State.GOING_TO_ATTACK_TARGET:
		_process_going_to_attack_target(delta)
	elif _state == State.ATTACKING:
		_process_attacking(delta)
	else:
		_move_direction = Vector3.ZERO
	
	if _state != State.ATTACKING:
		anim_player.play("Walk")
	
	
	if _command_state == CommandState.FOLLOWING:
		if global_position.distance_to(_current_master.global_position) > \
		max_distance_from_master:
			_get_close_to_master(_current_master)
	


func _process_attacking(delta: float) -> void:
	if attack_component.can_attack():
		attack_range.monitoring = true
		for body in attack_range.get_overlapping_bodies():
			if body == _attack_target:
				anim_player.play("Attack")
				var attack_direction = global_position.direction_to(_attack_target.global_position)
				attack_component.start_attack(attack_direction)
	elif _attack_target != null and not attack_component.is_attacking():
		set_attack_target(_attack_target)
		attack_range.monitoring = true


func _process_going_to_attack_target(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time and _attack_target:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _attack_target.global_position
	
	if not _navigation_agent.is_navigation_finished():
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		_move_direction = direction.normalized()
	else:
		_move_direction = Vector3.ZERO
		_state = State.ATTACKING


func _process_get_close_to_master(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time and _current_master:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _current_master.global_position
	
	if _current_master == null:
		# get new master or become idle
		pass
	if not _navigation_agent.is_navigation_finished() and \
	global_position.distance_to(_current_master.global_position) > move_with_master_distance:
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		_move_direction = direction.normalized()
	else:
		if not find_and_set_closet_target():
			_state = State.WALK_WTIH_MASTER


func _process_move_with_master(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	_move_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		
	if global_position.distance_to(_current_master.global_position) > \
	move_with_master_distance:
		_get_close_to_master(_current_master)


func make_follow(master: Player) -> void:
	if _command_state != CommandState.FOLLOWING:
		_command_state = CommandState.FOLLOWING
		_get_close_to_master(master)
		_set_follow_node(master.follow_node)


func unfollow() -> void:
	if _command_state != CommandState.STAYING:
		_command_state = CommandState.STAYING
		_state = State.STAY
		_stay_pos = global_position
		_follow_node = null


func _set_follow_node(follow_node: FollowNode) -> void:
	_follow_node = follow_node

func set_selection_visible(visible:bool) -> void:
	if visible:
		selection.show()
	else:
		selection.hide()

func _get_close_to_master(master: RigidBody3D) -> void:
	_state = State.GET_CLOSE_TO_MASTER
	_current_master = master
	elapsed_time = 0
	_navigation_agent.target_position = _current_master.global_position
	anim_player.play("Walk")


func attack_range_entered(body: Node3D) -> void:
	if body == _attack_target:
		if _state == State.GOING_TO_ATTACK_TARGET:
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
	if _attack_target == body:
		find_and_set_closet_target()


func set_attack_target(target: Node3D) -> void:
	elapsed_time = 0
	disconnect_signal_from_target()
	_attack_target = target
	connect_signal_to_target()
	_state = State.GOING_TO_ATTACK_TARGET
	if _navigation_agent:
		_navigation_agent.target_position = _attack_target.global_position


func disconnect_signal_from_target() -> void:
	if not _attack_target:
		return
	if _attack_target is Character:
		var other_char := _attack_target as Character
		other_char.dying.disconnect(target_died)
	elif _attack_target is Building:
		var building := _attack_target as Building
		building.dying.disconnect(target_died)


func connect_signal_to_target() -> void:
	if not _attack_target:
		return
	if _attack_target is Character:
		var other_char := _attack_target as Character
		other_char.dying.connect(target_died)
	elif _attack_target is Building:
		var building := _attack_target as Building
		building.dying.connect(target_died)


func find_and_set_closet_target() -> bool:
	var new_target: Node3D = null
	var shortest_dist: float = 1000000000000.0
	for target in _aggro_targets:
		var cur_dist := global_position.distance_to(target.global_position)
		if (new_target and target is Character and new_target is Building) or \
		(cur_dist < shortest_dist):
			new_target = target
			shortest_dist = cur_dist
	if new_target:
		set_attack_target(new_target)
		return true
	else:
		# return back to master or stay position
		_attack_target = null
		return false


func target_died(target: Node3D) -> void:
	if find_and_set_closet_target():
		_state = State.GOING_TO_ATTACK_TARGET
	elif _command_state == CommandState.FOLLOWING:
		_get_close_to_master(_current_master)
	elif _command_state == CommandState.STAYING:
		_state = State.STAY
