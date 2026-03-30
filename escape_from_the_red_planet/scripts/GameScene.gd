extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UIManager.instance.show_panel("PlayerMain")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()