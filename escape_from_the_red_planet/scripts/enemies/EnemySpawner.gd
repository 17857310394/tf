extends Node3D

# 敌人类型枚举
enum EnemyType {
	GROUND_ENEMY,
	FLYING_ENEMY,
	AI_ENEMY
}

# 波次配置 - 支持混合刷怪
@export var waves = [
	# 第一波：混合地面和飞行敌人
	{ 
		"enemies": [
			{ "count": 3, "type": EnemyType.GROUND_ENEMY },
			{ "count": 2, "type": EnemyType.FLYING_ENEMY }
		], 
		"spawn_interval": 1.0, 
		"rest_time": 20.0 
	}	
]

# 生成位置
@export var spawn_position = Vector3.ZERO
# 目标位置
@export var target_position = Vector3(100, 0, 100)

# 内部变量
var current_wave = 0
var enemies_spawned = {}  # 跟踪每种敌人的生成数量
var total_enemies_spawned = 0  # 跟踪当前波次总共生成的敌人数量
var wave_timer = 0.0
var rest_timer = 0.0
var is_spawning = false
var is_resting = false
var spawn_points = []

func _ready():
	# 收集所有刷怪点
	_collect_spawn_points()
	# 开始第一波敌人
	_start_wave()

func _collect_spawn_points():
	# 查找 enemySpawner 节点
	var enemy_spawner = get_tree().get_root().get_node("GameScene/enemySpawner")
	if enemy_spawner:
		# 收集所有 spawer 节点
		for child in enemy_spawner.get_children():
			if child.name.begins_with("spawner"):
				spawn_points.append(child.global_position)
		print("Collected spawn points:", spawn_points.size())
	else:
		print("Warning: enemySpawner node not found")

func _process(delta):
	return
	if is_spawning:
		# 生成敌人
		wave_timer += delta
		if current_wave < waves.size():
			var wave = waves[current_wave]
			if wave_timer >= wave.spawn_interval:
				# 计算当前波次的总敌人数量
				var total_enemies = 0
				for enemy_info in wave.enemies:
					total_enemies += enemy_info.count
				
				# 检查是否还有敌人需要生成
				if total_enemies_spawned < total_enemies:
					# 随机选择一种敌人类型
					var available_enemies = []
					for enemy_info in wave.enemies:
						var spawned = enemies_spawned.get(enemy_info.type, 0)
						if spawned < enemy_info.count:
							available_enemies.append(enemy_info.type)
					
					if available_enemies.size() > 0:
						# 随机选择一个敌人类型
						var random_index = randi() % available_enemies.size()
						var selected_enemy = available_enemies[random_index]
						
						# 生成敌人
						_spawn_enemy(selected_enemy)
						
						# 更新计数
						enemies_spawned[selected_enemy] = enemies_spawned.get(selected_enemy, 0) + 1
						total_enemies_spawned += 1
						wave_timer = 0.0
				else:
					# 波次结束，进入休息时间
					is_spawning = false
					is_resting = true
					rest_timer = 0.0
					print("Wave ", current_wave + 1, " completed")

	elif is_resting:
		# 休息时间
		rest_timer += delta
		if current_wave < waves.size():
			var wave = waves[current_wave]
			if rest_timer >= wave.rest_time:
				# 休息结束，开始下一波
				is_resting = false
				current_wave += 1
				if current_wave < waves.size():
					enemies_spawned = {}
					total_enemies_spawned = 0
					wave_timer = 0.0
					is_spawning = true
					print("Starting wave ", current_wave + 1)
				else:
					# 所有波次完成
					print("All waves completed")

func _start_wave():
	# 开始新的波次
	if current_wave < waves.size():
		enemies_spawned = {}
		total_enemies_spawned = 0
		wave_timer = 0.0
		is_spawning = true
		is_resting = false
		print("Starting wave ", current_wave + 1)

func _spawn_enemy(enemy_type: int):
	# 根据敌人类型生成敌人
	var enemy_scene_path = _get_enemy_scene_path(enemy_type)
	var enemy_scene = load(enemy_scene_path)
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		if enemy:
			# 随机选择一个刷怪点
			var spawn_pos = spawn_position
			if spawn_points.size() > 0:
				var random_index = randi() % spawn_points.size()
				spawn_pos = spawn_points[random_index]
				print("Spawning at random position:", spawn_pos)
			# 添加到场景
			add_child(enemy)
			# 设置生成位置
			enemy.global_position = spawn_pos
			# 设置目标位置
			if enemy.has_method("set_target_position"):
				enemy.set_target_position(target_position)
			print("Spawned ", _get_enemy_name(enemy_type))
	else:
		print("Error: Enemy scene not found: ", enemy_scene_path)

func _get_enemy_scene_path(enemy_type: int) -> String:
	# 根据枚举值获取敌人场景路径
	match enemy_type:
		EnemyType.GROUND_ENEMY:
			return "res://scenes/enemies/GroundEnemy.tscn"
		EnemyType.FLYING_ENEMY:
			return "res://scenes/enemies/FlyingEnemy.tscn"
		EnemyType.AI_ENEMY:
			return "res://scenes/enemies/AiEnemy.tscn"
		_:
			return ""
		

func _get_enemy_name(enemy_type: int) -> String:
	# 根据枚举值获取敌人名称
	match enemy_type:
		EnemyType.GROUND_ENEMY:
			return "GroundEnemy"
		EnemyType.FLYING_ENEMY:
			return "FlyingEnemy"
		EnemyType.AI_ENEMY:
			return "AiEnemy"
		_:
			return "Unknown Enemy"
		

func start_waves():
	# 开始所有波次
	current_wave = 0
	_start_wave()

func stop_waves():
	# 停止生成敌人
	is_spawning = false
	is_resting = false

func get_current_wave() -> int:
	return current_wave + 1

func get_total_waves() -> int:
	return waves.size()
