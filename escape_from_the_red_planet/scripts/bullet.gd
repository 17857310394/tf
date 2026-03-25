# bullet.gd
# 子弹脚本
# 实现子弹的移动、碰撞检测和生命周期管理

extends Area3D

# 子弹属性
var target: Node3D
var damage: float = 10.0
var speed: float = 50.0

# 初始化
func _ready():
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	# 连接定时器信号
	$Timer.timeout.connect(_on_timer_timeout)

# 更新
func _process(delta):
	if target and is_instance_valid(target):
		# 计算移动方向
		var direction = (target.global_position - global_position).normalized()
		# 移动子弹
		global_position += direction * speed * delta
	else:
		# 目标不存在，销毁子弹
		queue_free()

# 碰撞检测
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		# 对敌人造成伤害
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# 销毁子弹
		queue_free()

# 生命周期结束
func _on_timer_timeout():
	queue_free()
