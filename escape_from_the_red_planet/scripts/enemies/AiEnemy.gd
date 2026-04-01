extends CharacterBody3D

# AI 敌人属性
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
var is_dead = false

signal signal_take_damage(amount: float)

func _ready():
	# 添加到敌人组
	add_to_group("enemies")


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

	move_and_slide()


func take_damage(amount: float, body_shape_index: int):
	# 计算伤害（考虑弱点系统）
	var final_damage = amount
	# 检查是否有弱点检测器
	var weak_point_detector = get_node_or_null("WeakPointDetector")
	if weak_point_detector and weak_point_detector.has_method("calculate_damage"):
		final_damage = weak_point_detector.calculate_damage(amount, body_shape_index)

	current_health -= final_damage
	print("AI Enemy took damage: ", final_damage, " Current health: ", current_health)

	signal_take_damage.emit(final_damage)
	if current_health <= 0:
		_die()

func _die():
	is_dead = true
	print("AI Enemy died")
	# 这里可以添加死亡动画和特效
	# 延迟后删除敌人
	queue_free()

func _on_reach_target():
	# 到达目标点的逻辑
	print("Enemy reached target")
	# 敌人完成任务后销毁
	queue_free()

func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

# 获取移动速度
func get_movement_speed():
	return movement_speed

# 获取攻击伤害
func get_attack_damage():
	return attack_damage

# 获取敌人类型
func get_enemy_type():
	return enemy_type
