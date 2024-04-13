class_name Grunt extends Character

@export var speed: float = 9.5
@export var path_calc_time: float = 0.1
@export var max_distance_from_master: float = 4.0
var elapsed_time: float = 0

@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

var _target: Node3D = null

enum State {
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_navigation_agent.target_desired_distance = 2.5
	_navigation_agent.path_desired_distance = 2
	if _target:
		_navigation_agent.target_position = _target.global_position


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _navigation_agent.is_navigation_finished():
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		direction = direction.normalized()
		linear_velocity = direction * speed
	else:
		pass


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _target.global_position


func set_target(target: Node3D) -> void:
	elapsed_time = 0
	_target = target
	if _navigation_agent:
		_navigation_agent.target_position = _target.global_position
