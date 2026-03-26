extends Node

# 事件系统使用示例

func _ready() -> void:
	print("=== 事件系统使用示例 ===")
	
	# 示例1：基本事件监听
	print("\n示例1：基本事件监听")
	EventSystem.instance.on("player_jump", _on_player_jump)
	EventSystem.instance.emit("player_jump", "Player1", 10.5)
	
	# 示例2：一次性事件
	print("\n示例2：一次性事件")
	EventSystem.instance.once("game_start", _on_game_start)
	EventSystem.instance.emit("game_start", "Level 1")
	EventSystem.instance.emit("game_start", "Level 2")  # 不会触发
	
	# 示例3：事件优先级
	print("\n示例3：事件优先级")
	EventSystem.instance.on("enemy_spawn", _on_enemy_spawn_low, 1)
	EventSystem.instance.on("enemy_spawn", _on_enemy_spawn_high, 10)
	EventSystem.instance.emit("enemy_spawn", "Goblin", 5)
	
	# 示例4：注销事件
	print("\n示例4：注销事件")
	EventSystem.instance.off("player_jump", _on_player_jump)
	EventSystem.instance.emit("player_jump", "Player1", 15.0)  # 不会触发
	
	# 示例5：多监听器
	print("\n示例5：多监听器")
	EventSystem.instance.on("score_update", _on_score_update_ui)
	EventSystem.instance.on("score_update", _on_score_update_log)
	EventSystem.instance.emit("score_update", 1000)
	
	# 示例6：节流事件
	print("\n示例6：节流事件")
	for i in range(5):
		EventSystem.instance.throttle("button_click", func():
			print("Button clicked (throttled)")
		, 1.0)
	
	# 示例7：防抖事件
	print("\n示例7：防抖事件")
	for i in range(5):
		EventSystem.instance.debounce("input_change", func():
			print("Input changed (debounced)")
		, 0.5)

func _on_player_jump(event_name: String, player_name: String, height: float) -> void:
	print("Player " + player_name + " jumped " + str(height) + " units")

func _on_game_start(event_name: String, level: String) -> void:
	print("Game started on " + level)

func _on_enemy_spawn_low(event_name: String, enemy_type: String, count: int) -> void:
	print("Low priority: Spawned " + str(count) + " " + enemy_type + "(s)")

func _on_enemy_spawn_high(event_name: String, enemy_type: String, count: int) -> void:
	print("High priority: Spawned " + str(count) + " " + enemy_type + "(s)")

func _on_score_update_ui(event_name: String, score: int) -> void:
	print("UI: Score updated to " + str(score))

func _on_score_update_log(event_name: String, score: int) -> void:
	print("Log: Score updated to " + str(score))
