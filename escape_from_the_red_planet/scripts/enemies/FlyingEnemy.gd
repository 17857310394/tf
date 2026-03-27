extends CharacterBody3D

# 敌人属性
@export var max_health = 80
@export var move_speed = 4.0
@export var attack_damage = 15
@export var reward_gold = 75
@export var flying_height = 5.0

# 内部变量
var current_health = max_health
var target_position = Vector3.ZERO
var is_dead = false

func _ready():
	# 添加到敌人组
	add_to_group("enemies")
	# 设置初始飞行高度
	position.y = flying_height
	# 设置目标位置（这里需要根据实际场景设置）
	target_position = Vector3(100, flying_height, 100)

func _process(delta):
	if is_dead:
		return

	# 移动逻辑
	_move_towards_target()

func _move_towards_target():
	var direction = (target_position - global_position).normalized()
	var velocity = direction * move_speed
	# 保持飞行高度
	velocity.y = 0
	move_and_slide()

	# 检查是否到达目标
	if global_position.distance_to(target_position) < 1.0:
		_on_reach_target()

func take_damage(amount: float, hit_position: Vector3 = Vector3.ZERO):
	# 计算伤害（考虑弱点系统）
	var final_damage = amount
	# 检查是否有弱点检测器
	var weak_point_detector = get_node_or_null("WeakPointDetector")
	if weak_point_detector and weak_point_detector.has_method("calculate_damage"):
		final_damage = weak_point_detector.calculate_damage(amount, hit_position)

	current_health -= final_damage
	print("Flying enemy took damage: ", final_damage, " Current health: ", current_health)

	if current_health <= 0:
		_die()

func _die():
	is_dead = true
	print("Flying enemy died")
	# 这里可以添加死亡动画和特效
	# 延迟后删除敌人
	queue_free()

func _on_reach_target():
	# 到达目标点的逻辑
	print("Flying enemy reached target")
	# 这里可以处理敌人到达终点的逻辑，例如减少玩家生命值
	queue_free()

func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

func set_target_position(position: Vector3):
	target_position = Vector3(position.x, flying_height, position.z)
