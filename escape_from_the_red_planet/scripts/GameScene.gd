extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UiManager.instance.show_panel("PlayerMain")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
