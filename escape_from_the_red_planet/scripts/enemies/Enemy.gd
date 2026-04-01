extends CharacterBody3D

# 敌人属性
@export var max_health = 100
@export var movement_speed: float = 2.0
@export var attack_damage = 10
@export var reward_gold = 50
# 敌人类型枚举
enum EnemyType {
	GROUND,
	FLY
}

@export var enemy_type: EnemyType = EnemyType.GROUND

# 物理相关属性
@export var gravity_scale: float = 1.0  # 重力缩放，值越大下落越快
@export var max_fall_speed: float = 50.0  # 最大下落速度

# 内部变量
var current_health = max_health
var navigation_agent = null
var target_position = Vector3.ZERO
var target_tower: Node3D = null  # 缓存目标防御塔
var is_dead = false

func _ready():
	# 添加到敌人组
	add_to_group("enemies")
	
	# 获取导航代理
	navigation_agent = get_node_or_null("NavigationAgent3D")
	if navigation_agent:
		# 初始设置一个默认目标
		target_position = Vector3(100, 0, 100)
		navigation_agent.target_position = target_position
		if enemy_type == EnemyType.FLY:
			navigation_agent.layer = 2

func _physics_process(delta):
	# 应用重力（无论是否死亡）
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale
	velocity.y -= gravity * delta
	
	# 限制最大下落速度
	if velocity.y < -max_fall_speed:
		velocity.y = -max_fall_speed

	if is_dead:
		# 死亡后只处理下落
		move_and_slide()
		return

	# 定期更新目标（每0.5秒）
	if int(Engine.get_process_frames() % 30) == 0:
		_update_target()

	# 导航逻辑
	if navigation_agent:
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			return
		if navigation_agent.is_navigation_finished():
			# 到达目标，这里可以处理到达终点的逻辑
			_on_reach_target()
			return

		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
		# 保持垂直速度，只更新水平速度
		if enemy_type != EnemyType.FLY:
			new_velocity.y = velocity.y
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
	else:
		# 如果没有导航代理，直接移动
		move_and_slide()

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func _update_target():
	# 检测附近的防御塔和主城
	var potential_targets = []
	
	# 1. 检测所有防御塔
	var towers = get_tree().get_nodes_in_group("tower")
	for tower in towers:
		if tower and is_instance_valid(tower):
			potential_targets.append({
				"node": tower,
				"distance": global_position.distance_to(tower.global_position)
			})
	
	# 2. 检测主城（假设主城在"base"组中）
	var bases = get_tree().get_nodes_in_group("base")
	for base in bases:
		if base and is_instance_valid(base):
			potential_targets.append({
				"node": base,
				"distance": global_position.distance_to(base.global_position)
			})
	
	# 3. 选择最近的目标
	if potential_targets.size() > 0:
		# 按距离排序
		potential_targets.sort_custom(func(a, b): return a.distance < b.distance)
		# 设置最近的目标
		var closest_target = potential_targets[0]
		target_position = closest_target.node.global_position
		# 缓存目标防御塔（如果目标是防御塔）
		target_tower = closest_target.node
		if navigation_agent:
			navigation_agent.target_position = target_position

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
	
	# 检查是否有缓存的目标防御塔
	if target_tower and is_instance_valid(target_tower):
		# 对防御塔造成伤害
		if target_tower.has_method("take_damage"):
			target_tower.take_damage(attack_damage)
			print("Enemy attacked tower, dealing ", attack_damage, " damage")
	
	# 敌人完成任务后销毁
	queue_free()

func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

func set_target_position(position: Vector3):
	target_position = position
	if navigation_agent:
		navigation_agent.target_position = target_position
