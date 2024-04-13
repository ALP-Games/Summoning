class_name Player extends RigidBody3D

@export var speed: float = 10.0
@export var selection: PackedScene = null

@onready var camera: Camera3D = $Camera3D
@onready var follow_node: FollowNode = $FollowNode

var minions_selected: Array[Minion] = []
var click_selection: Minion = null

var mouse_held: bool = false
var world_click_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_proccess_left_mouse_button(mouse_event)
	if event is InputEventMouseMotion:
		_process_mouse_motion(event)


func _process_mouse_motion(motion_event: InputEventMouseMotion) -> void:
	if mouse_held:
		var world_click := _process_world_click(1)
		


func _proccess_left_mouse_button(mouse_event: InputEventMouseButton) -> void:
	if mouse_event.pressed:
		var intersection := _process_world_click()
		if intersection.size() > 0 and intersection.collider is Minion:
			click_selection = intersection.collider
		var world_click := _process_world_click(1)
		if world_click.size() > 0:
			mouse_held = true
			world_click_pos = world_click.position
	elif not mouse_event.pressed:
		mouse_held = false
		var intersection := _process_world_click()
		# if we havent started drawing a box
		if intersection.size() > 0 and intersection.collider == click_selection:
			minions_selected = [intersection.collider]
		else:
			minions_selected = []
		click_selection = null


func _process_world_click(collision_mask: int = 0xFFFFFFFF) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var mouse_position := get_viewport().get_mouse_position()
	var rayOrigin := camera.project_ray_origin(mouse_position)
	var rayEnd := rayOrigin + camera.project_ray_normal(mouse_position) * 1000
	return space_state.intersect_ray(\
		PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, collision_mask))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
	linear_velocity = movement_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("follow"):
		for minion in minions_selected:
			follow_node.add_new_folower(minion)
