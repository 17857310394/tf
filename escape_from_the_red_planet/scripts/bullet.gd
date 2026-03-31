# bullet.gd
# 子弹脚本
# 处理子弹的飞行和碰撞逻辑

class_name Bullet extends RigidBody3D

var damage: float = 10  # 伤害值
var speed: float = 50  # 飞行速度
var lifetime: float = 2.0  # 生命周期
var timer: float = 0  # 计时器
var target: Node3D = null  # 目标（用于自动攻击模式）
var has_damage: bool = false  # 是否已造成伤害标志

# 初始化
func _ready():
	$Area3D.body_shape_entered.connect(_on_body_entered)
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
func _on_body_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int):
	if body.is_in_group("enemies"):
		if has_damage:
			return  # 已造成伤害，不重复处理

		if target:
			# 自动攻击模式：固定伤害
			body.take_damage(damage,1)
		else:
			body.take_damage(damage,body_shape_index)
		
		has_damage = true	
		# 销毁子弹
		queue_free()
		
