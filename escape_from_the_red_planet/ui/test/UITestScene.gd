extends Node

# UI系统测试场景

func _ready() -> void:
	print("=== UI系统测试开始 ===")
	
	# 测试1：显示主菜单
	print("测试1：显示主菜单")
	UIManager.instance.show_panel("MainMenu")
	
	#测试2：注册事件
	print("测试2：注册事件")
	UIManager.instance.register_event("game_start", _on_game_start)
	UIManager.instance.register_event("volume_changed", _on_volume_changed)
	
	# 测试3：预加载面板
	print("测试3：预加载面板")
	UIManager.instance.preload_panels(["Settings"])

func _on_game_start(data: Dictionary) -> void:
	print("事件触发：game_start")

func _on_volume_changed(data: Dictionary) -> void:
	print("事件触发：volume_changed，音量: " + str(data.get("volume")))
