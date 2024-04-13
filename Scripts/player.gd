extends RigidBody3D

@export var speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
	linear_velocity = movement_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
