extends CharacterBody3D

# 敌人属性
@export var max_health = 100
@export var move_speed = 3.0
@export var attack_damage = 10
@export var reward_gold = 50
# 敌人类型枚举
enum EnemyType {
	GROUND,
	FLY
}

@export var enemy_type: EnemyType = EnemyType.GROUND

# 内部变量
var current_health = max_health
var navigation_agent = null
var target_position = Vector3.ZERO
var is_dead = false

func _ready():
	# 添加到敌人组
	add_to_group("enemies")
	# # 获取导航代理
	# navigation_agent = get_node_or_null("NavigationAgent3D")
	# if navigation_agent:
	# 	# 设置目标位置（这里需要根据实际场景设置）
	# 	target_position = Vector3(100, 0, 100)
	# 	navigation_agent.target_position = target_position

func _process(delta):
	pass
	# if is_dead:
	# 	return

	# # 移动逻辑
	# if navigation_agent and navigation_agent.is_navigation_finished():
	# 	# 到达目标，这里可以处理到达终点的逻辑
	# 	_on_reach_target()
	# else:
	# 	_move_towards_target()

func _move_towards_target():
	if navigation_agent:
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		var velocity = direction * move_speed
		move_and_slide()

func take_damage(amount: float,body_shape_index:int):
	# 计算伤害（考虑弱点系统）
	var final_damage = amount
	# 检查是否有弱点检测器
	var weak_point_detector = get_node_or_null("WeakPointDetector")
	if weak_point_detector and weak_point_detector.has_method("calculate_damage"):
		final_damage = weak_point_detector.calculate_damage(amount, body_shape_index)

	current_health -= final_damage
	print("Enemy took damage: ", final_damage, " Current health: ", current_health)

	if current_health <= 0:
		_die()

func _die():
	is_dead = true
	print("Enemy died")
	# 这里可以添加死亡动画和特效
	# 延迟后删除敌人
	queue_free()

func _on_reach_target():
	# 到达目标点的逻辑
	print("Enemy reached target")
	# 这里可以处理敌人到达终点的逻辑，例如减少玩家生命值
	queue_free()

func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

func set_target_position(position: Vector3):
	target_position = position
	if navigation_agent:
		navigation_agent.target_position = target_position
