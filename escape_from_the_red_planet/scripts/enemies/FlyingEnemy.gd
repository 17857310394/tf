extends "./Enemy.gd"

# 飞行敌人特有属性
@export var flight_height: float = 8.0  # 飞行高度
@export var flight_speed: float = 2.0  # 飞行速度

func _ready():
	super()
	# 设置敌人类型为飞行
	enemy_type = EnemyType.FLY
	# 调整初始位置到飞行高度
	global_position.y = flight_height
	# 使用飞行速度
	movement_speed = flight_speed

func _die():
	is_dead = true
	print("Flying enemy died")
	# 这里可以添加死亡动画和特效
	# 延迟后删除敌人
	queue_free()
