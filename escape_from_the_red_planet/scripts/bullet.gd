# bullet.gd
# 子弹脚本
# 处理子弹的飞行和碰撞逻辑

class_name Bullet extends RigidBody3D

var damage: float = 10  # 伤害值
var speed: float = 50  # 飞行速度
var lifetime: float = 2.0  # 生命周期
var timer: float = 0  # 计时器
var target: Node3D = null  # 目标（用于自动攻击模式）

# 初始化
func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	if target:
		# 自动攻击模式：追踪目标
		var direction = (target.global_position - global_position).normalized()
		linear_velocity = direction * speed
		# 旋转子弹朝向目标
		look_at(target.global_position, Vector3.UP)
	else:
		# 第一人称模式：沿直线飞行
		linear_velocity = transform.basis.z * -speed

# 更新
func _process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()
	
	# 如果有目标且目标存在，更新飞行方向和朝向
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		linear_velocity = direction * speed

# 碰撞检测
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		# 对敌人造成伤害
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# 销毁子弹
		queue_free()
