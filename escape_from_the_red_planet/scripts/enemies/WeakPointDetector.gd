extends Node3D

# 弱点部位节点路径
@export var weak_point_nodes = []
# 弱点伤害倍率
@export var weak_point_multiplier = 2.0
# 非弱点伤害倍率
@export var normal_multiplier = 1.0

# 敌人引用
var enemy = null

func _ready():
	# 获取敌人引用
	enemy = get_parent()
	# 为弱点部位添加碰撞体和信号连接
	_setup_weak_points()

func _setup_weak_points():
	# 遍历弱点部位节点
	for node_path in weak_point_nodes:
		var weak_point = enemy.get_node_or_null(node_path)
		if weak_point and weak_point is Area3D:
			# 连接碰撞信号
			weak_point.connect("area_entered", Callable(self, "_on_weak_point_entered"))
			weak_point.connect("body_entered", Callable(self, "_on_weak_point_entered"))

func _on_weak_point_entered(body):
	# 处理弱点部位被击中的逻辑
	# 这里可以通过信号或其他方式通知敌人受到伤害
	print("Weak point hit!")

func calculate_damage(base_damage: float, hit_position: Vector3 = Vector3.ZERO) -> float:
	# 计算最终伤害
	var multiplier = normal_multiplier
	
	# 检查是否命中弱点部位
	if _is_hit_weak_point(hit_position):
		multiplier = weak_point_multiplier
	
	return base_damage * multiplier

func _is_hit_weak_point(hit_position: Vector3) -> bool:
	# 检查命中位置是否在弱点部位
	for node_path in weak_point_nodes:
		var weak_point = enemy.get_node_or_null(node_path)
		if weak_point and weak_point is Area3D:
			# 检查命中位置是否在弱点部位的碰撞体内
			# 这里需要根据实际的碰撞体类型进行判断
			# 简化版：检查距离
			if weak_point.global_position.distance_to(hit_position) < 1.0:
				return true
	
	return false

func get_weak_point_multiplier() -> float:
	return weak_point_multiplier

func get_normal_multiplier() -> float:
	return normal_multiplier
