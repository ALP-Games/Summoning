class_name Minion extends RigidBody3D

@export var speed: float = 8.0
@export var _temp_master: RigidBody3D = null
@export var path_calc_time: float = 0.1
var elapsed_time: float = 0

@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_navigation_agent.target_desired_distance = 2.5
	_navigation_agent.path_desired_distance = 2


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _navigation_agent.is_navigation_finished():
		var nex_path_position := _navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(nex_path_position)
		direction.y = 0
		direction = direction.normalized()
		linear_velocity = direction * speed
	else:
		linear_velocity = Vector3.ZERO
	#var input_dir := Input.get_vector("left", "right", "up", "down")
	#var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
	#linear_velocity = movement_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	
	if elapsed_time >= path_calc_time and _temp_master:
		elapsed_time -= path_calc_time
		_navigation_agent.target_position = _temp_master.global_position
