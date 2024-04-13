class_name Grunt extends Character

@export var speed: float = 9.5
@export var path_calc_time: float = 0.1
@export var distance_to_enemy: float = 2.5
var elapsed_time: float = 0

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
	_navigation_agent.target_desired_distance = distance_to_enemy
	_navigation_agent.path_desired_distance = 2.0
	if _target:
		_navigation_agent.target_position = _target.global_position


func _physics_process(delta: float) -> void:
	if _state == State.IDLE:
		pass
	elif _state == State.GOING_TO_TARGET:
		_process_going_to_target(delta)
	elif _state == State.ATTACKING:
		_process_attack(delta)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = _move_direction * speed


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
	#if global_position.distance_to() distance_to_enemy
	pass


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _target.global_position


func set_target(target: Node3D) -> void:
	elapsed_time = 0
	_target = target
	_state = State.GOING_TO_TARGET
	if _navigation_agent:
		_navigation_agent.target_position = _target.global_position
