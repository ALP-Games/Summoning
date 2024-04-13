class_name GruntSpawner extends Building

@export var spawn_interval: float = 5.0
@export var grunt: PackedScene = null

var elapsed_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= spawn_interval:
		elapsed_time -= spawn_interval
		var grunt_instance = grunt.instantiate()
		game_manager.gameplay.entities.add_child(grunt_instance)
