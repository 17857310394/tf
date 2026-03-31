extends Node3D

# 弱点部位配置
@export var weak_point_configs = [
    {"shape_index": 0, "part_name": "head", "multiplier": 2.0},
    {"shape_index": 1, "part_name": "body", "multiplier": 1.0}
]
# 非弱点默认伤害倍率
@export var normal_multiplier = 1.0

# 敌人引用
var enemy = null

func _ready():
	# 获取敌人引用
	enemy = get_parent()

func calculate_damage(base_damage: float, body_shape_index:int) -> float:
	# 检查是否命中弱点部位
	var multiplier = get_weak_point_multiplier(body_shape_index)
	
	return base_damage * multiplier

func get_weak_point_multiplier(body_shape_index:int) -> float:
	for config in weak_point_configs:
		if config.shape_index == body_shape_index:
			return config.multiplier
	return normal_multiplier

func get_normal_multiplier() -> float:
	return normal_multiplier
