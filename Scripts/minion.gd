class_name Minion extends RigidBody3D

@export var speed: float = 8.0
@export var path_calc_time: float = 0.1
@export var max_distance_from_master: float = 4.0
var elapsed_time: float = 0

@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

enum State {
	GET_CLOSE_TO_MASTER,
	WALK_WTIH_MASTER,
	STAY
}
var _state: State = State.STAY
var _current_master: RigidBody3D = null
var _follow_node: FollowNode = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_navigation_agent.target_desired_distance = 2.5
	_navigation_agent.path_desired_distance = 2


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _state == State.GET_CLOSE_TO_MASTER:
		if _current_master == null:
			# get new master or become idle
			pass
		if not _navigation_agent.is_navigation_finished():
			var nex_path_position := _navigation_agent.get_next_path_position()
			var direction := global_position.direction_to(nex_path_position)
			direction.y = 0
			direction = direction.normalized()
			linear_velocity = direction * speed
		else:
			# Walk with master
			_state = State.WALK_WTIH_MASTER
	elif _state == State.WALK_WTIH_MASTER:
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
		linear_velocity = movement_velocity
		if global_position.distance_to(_current_master.global_position) > \
		max_distance_from_master:
			get_close_to_master(_current_master)
		# need to check if is too far from master
	else:
		linear_velocity = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= path_calc_time and \
	_current_master and _state == State.GET_CLOSE_TO_MASTER:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _current_master.global_position


func set_follow_node(follow_node: FollowNode) -> void:
	_follow_node = follow_node


func get_close_to_master(master: RigidBody3D) -> void:
	_state = State.GET_CLOSE_TO_MASTER
	_current_master = master
	elapsed_time = 0
	_navigation_agent.target_position = _current_master.global_position
	
