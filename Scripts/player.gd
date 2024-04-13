class_name Player extends RigidBody3D

@export var speed: float = 10.0

@onready var camera: Camera3D = $Camera3D
@onready var follow_node: FollowNode = $FollowNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var space_state := get_world_3d().direct_space_state
			var mouse_position := get_viewport().get_mouse_position()
			var rayOrigin := camera.project_ray_origin(mouse_position)
			var rayEnd := rayOrigin + camera.project_ray_normal(mouse_position) * 2000
			var intersection := space_state.intersect_ray(\
				PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
			if intersection.size() > 0 and intersection.collider is Minion:
				var minion := intersection.collider as Minion
				follow_node.add_new_folower(minion)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
	linear_velocity = movement_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
