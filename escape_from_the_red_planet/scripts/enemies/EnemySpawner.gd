extends Node3D

# 波次配置
@export var waves = [
	{ "enemy_count": 5, "enemy_type": "GroundEnemy", "spawn_interval": 1.0, "rest_time": 5.0 },
	{ "enemy_count": 10, "enemy_type": "GroundEnemy", "spawn_interval": 0.8, "rest_time": 5.0 },
	{ "enemy_count": 8, "enemy_type": "FlyingEnemy", "spawn_interval": 1.2, "rest_time": 5.0 },
	{ "enemy_count": 15, "enemy_type": "GroundEnemy", "spawn_interval": 0.6, "rest_time": 5.0 },
	{ "enemy_count": 12, "enemy_type": "FlyingEnemy", "spawn_interval": 1.0, "rest_time": 5.0 }
]

# 生成位置
@export var spawn_position = Vector3.ZERO
# 目标位置
@export var target_position = Vector3(100, 0, 100)

# 内部变量
var current_wave = 0
var enemies_spawned = 0
var wave_timer = 0.0
var rest_timer = 0.0
var is_spawning = false
var is_resting = false

func _ready():
	# 开始第一波敌人
	_start_wave()

func _process(delta):
	if is_spawning:
		# 生成敌人
		wave_timer += delta
		if current_wave < waves.size():
			var wave = waves[current_wave]
			if wave_timer >= wave.spawn_interval and enemies_spawned < wave.enemy_count:
				_spawn_enemy(wave.enemy_type)
				enemies_spawned += 1
				wave_timer = 0.0
			elif enemies_spawned >= wave.enemy_count:
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
					enemies_spawned = 0
					wave_timer = 0.0
					is_spawning = true
					print("Starting wave ", current_wave + 1)
				else:
					# 所有波次完成
					print("All waves completed")

func _start_wave():
	# 开始新的波次
	if current_wave < waves.size():
		enemies_spawned = 0
		wave_timer = 0.0
		is_spawning = true
		is_resting = false
		print("Starting wave ", current_wave + 1)

func _spawn_enemy(enemy_type: String):
	# 根据敌人类型生成敌人
	var enemy_scene = load("res://scenes/enemies/" + enemy_type + ".tscn")
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		if enemy:
			# 设置生成位置
			enemy.global_position = spawn_position
			# 设置目标位置
			if enemy.has_method("set_target_position"):
				enemy.set_target_position(target_position)
			# 添加到场景
			add_child(enemy)
			print("Spawned ", enemy_type)
	else:
		print("Error: Enemy scene not found: ", enemy_type)

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
