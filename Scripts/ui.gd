class_name UI extends Control

@export var player: Player

@export var selected_count_label: Label = null
@export var selection_info_label: Label = null

var selection_info_singular := "Minion selected"
var selection_info_plural := "Minions selected"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_count_label.text = "0x"
	selection_info_label.text = selection_info_plural


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var amount := player.minions_selected.size()
	selected_count_label.text = str(amount) + "x"
	if amount == 1:
		selection_info_label.text = selection_info_singular
	else:
		selection_info_label.text = selection_info_plural
