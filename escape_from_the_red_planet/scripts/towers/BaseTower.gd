# BaseTower.gd
# 防御塔基类
# 所有防御塔类型的父类，提供防御塔的基本功能和通用方法

class_name BaseTower extends Node3D

# 核心属性
@export var tower_data: TowerData  # 防御塔数据
var level: int = 1  # 防御塔等级
var current_health: float  # 当前生命值
var attack_cooldown: float = 0  # 攻击冷却时间

# 状态
var is_attacking: bool = false  # 是否正在攻击
var target: Node3D = null  # 当前攻击目标

# 第一人称控制相关属性
var is_player_controlled: bool = false  # 是否由玩家控制
var first_person_camera: Camera3D = null  # 第一人称相机
var player_controller: Node3D = null  # 玩家控制器引用
var camera_rotation: Vector3 = Vector3.ZERO  # 相机旋转状态
var mouse_sensitivity: float = 0.01  # 鼠标灵敏度
var max_pitch: float = PI/2  # 最大俯仰角度
var is_firing: bool = false  # 是否正在开火（长按状态）


# 技能系统
var skills = {}  # 技能字典，键为技能名称，值为技能数据和冷却时间

# 攻击范围可视化
var range_visualizer: MeshInstance3D  # 攻击范围可视化组件

# 信号
signal target_acquired(target)  # 获得目标时触发
signal target_lost()  # 失去目标时触发
signal attack_started()  # 开始攻击时触发
signal attack_completed()  # 攻击完成时触发
signal upgraded(new_level)  # 升级时触发
signal sold(value)  # 出售时触发
signal destroyed()  # 销毁时触发

# 初始化
# 功能：初始化防御塔的状态和组件
func _ready():
	# target_acquired.connect(on_target_acquired)
	current_health = tower_data.base_health
	initialize_skills()
	create_range_visualizer()
	initialize_area3d()

	sold.connect(on_sold)

# func on_target_acquired():
# 	pass

# 初始化技能
# 功能：从tower_data中初始化技能
func initialize_skills():
	for skill_data in tower_data.skills:
		skills[skill_data.name] = {
			"data": skill_data,
			"cooldown": 0
		}

# 更新
# 功能：处理防御塔的攻击冷却和目标选择
# 参数：
#   delta: 帧间隔时间
func _process(delta):
	attack_cooldown = max(0, attack_cooldown - delta)
	update_skills(delta)
	check_skill_triggers()
	
	# 第一人称控制冷却
	if is_player_controlled:
		# 处理长按开火
		if is_firing and attack_cooldown <= 0:
			fire()
	else:
		if not target:
			select_target()
		elif attack_cooldown <= 0:
			attack()

# 攻击方法（由子类实现）
# 功能：执行攻击逻辑
func attack():
	if not target:
		return

	is_attacking = true
	attack_started.emit()

	# 设置攻击冷却
	attack_cooldown = get_current_attack_speed()

	# 旋转塔朝向目标（只旋转y轴）
	var direction = (target.global_position - global_position)
	direction.y = 0
	if direction.length() > 0:
		direction = direction.normalized()
		# 使用atan2计算包含方向的角度
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = target_rotation

	is_attacking = false
	attack_completed.emit()

# 输入处理
# 功能：处理第一人称控制的输入
func _input(event):
	if not is_player_controlled:
		return
	
	# 鼠标控制视角
	if event is InputEventMouseMotion:
		if first_person_camera:
			# 垂直旋转（俯仰）：鼠标上下移动控制
			camera_rotation.x -= event.relative.y * mouse_sensitivity
			# 限制垂直旋转范围，防止过度旋转
			camera_rotation.x = clamp(camera_rotation.x, -max_pitch, max_pitch)
			
			# 水平旋转（偏航）：鼠标左右移动控制
			camera_rotation.y -= event.relative.x * mouse_sensitivity
			
			# 应用旋转到摄像机
			first_person_camera.rotation = camera_rotation
			# 应用水平旋转到防御塔（保持防御塔朝向与视角一致）
			rotation.y = camera_rotation.y
	
	# 开火
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_firing = true
		else:
			is_firing = false

# 目标选择
# 功能：选择攻击目标
func select_target():
	var area = $TriggerArea
	if not area:
		return
	
	var candidates = []
	
	# 获取范围内的敌人
	for body in area.get_overlapping_bodies():
		if body.is_in_group("enemies") and can_attack_target(body):
			candidates.append(body)
	
	if candidates.size() == 0:
		target = null
		target_lost.emit()
		return
	
	# 按照优先级排序
	candidates.sort_custom(_compare_targets)
	target = candidates[0]
	target_acquired.emit(target)

# 目标比较函数
# 功能：比较两个目标的优先级
# 参数：
#   a: 第一个目标
#   b: 第二个目标
# 返回值：
#   int: -1表示a优先级更高，1表示b优先级更高，0表示优先级相同
func _compare_targets(a: Node3D, b: Node3D) -> int:
	# 优先级1：距离最近（默认）
	var distance_a = global_position.distance_to(a.global_position)
	var distance_b = global_position.distance_to(b.global_position)
	if distance_a < distance_b:
		return -1
	if distance_a > distance_b:
		return 1
	
	# 优先级2：生命值最低（保留逻辑）
	var health_a = a.get("health")
	var health_b = b.get("health")
	if health_a < health_b:
		return -1
	if health_a > health_b:
		return 1
	
	# 优先级3：移动速度最快（保留逻辑）
	var speed_a = a.get("speed")
	var speed_b = b.get("speed")
	if speed_a > speed_b:
		return -1
	if speed_a < speed_b:
		return 1
	
	return 0

# 攻击目标判定
# 功能：判断防御塔是否可以攻击指定目标
# 参数：
#   target: 目标节点
# 返回值：
#   bool: 是否可以攻击
func can_attack_target(target: Node3D) -> bool:
	if not target:
		return false
	
	var target_type = 0
	if target.has_method("enemy_type"):
		target_type = target.enemy_type
	if(tower_data.attack_type == target.enemy_type):
		return true
	if(tower_data.attack_type == 2): # BOTH
		return true;
	return false

# 升级方法
# 功能：升级防御塔
func upgrade():
	# 检查 tower_data 是否存在
	if not tower_data:
		print("Error: tower_data is nil")
		return
	
	# 检查是否可以升级
	if level >= tower_data.max_level:
		print("Error: Tower has reached maximum level")
		return
	
	# 获取升级成本
	var upgrade_cost = tower_data.get_upgrade_cost(level)
	
	# 获取玩家数据
	var player_data = GameManager.instance.get_player_data()
	if not player_data:
		print("Error: PlayerData not found")
		return
	
	# 检查玩家是否有足够的金币
	if not player_data.remove_gold(upgrade_cost):
		print("Not enough gold to upgrade tower! Need: " + str(upgrade_cost))
		return
	
	# 执行升级
	level += 1
	current_health = get_max_health()
	if range_visualizer:
		var mesh = range_visualizer.mesh as SphereMesh
		mesh.radius = get_current_range()
	# 更新Area3D节点范围
	$TriggerArea/CollisionShape3D.shape.radius = get_current_range()

	play_upgrade_animation()
	upgraded.emit(level)
	print("Tower upgraded to level " + str(level) + ", cost: " + str(upgrade_cost))

# 获取最大生命值
# 功能：计算当前等级的最大生命值
# 返回值：
#   float: 最大生命值
func get_max_health() -> float:
	return tower_data.base_health * pow(tower_data.health_growth_rate, level - 1)

# 获取当前攻击力
# 功能：计算当前等级的攻击力
# 返回值：
#   float: 当前攻击力
func get_current_damage() -> float:
	return tower_data.base_damage * pow(tower_data.damage_growth_rate, level - 1)

# 获取当前攻击速度
# 功能：计算当前等级的攻击速度（攻击间隔）
# 返回值：
#   float: 当前攻击间隔（秒）
func get_current_attack_speed() -> float:
	return tower_data.base_attack_speed / pow(tower_data.attack_speed_growth_rate, level - 1)

# 获取当前攻击范围
# 功能：计算当前等级的攻击范围
# 返回值：
#   float: 当前攻击范围
func get_current_range() -> float:
	return tower_data.base_range * pow(tower_data.range_growth_rate, level - 1)

# 承受伤害
# 功能：处理防御塔受到的伤害
# 参数：
#   amount: 伤害量
func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	print("Tower took ", amount, " damage, current health: ", current_health)
	if current_health <= 0:
		destroyed.emit()
		queue_free()

# 出售
# 功能：出售防御塔并返回收益
# 返回值：
#   int: 出售获得的金币
func sell() -> void:
	var sell_value = get_sell_value()
	sold.emit(sell_value)
	queue_free()

func get_sell_value()->int:
	return int(tower_data.build_cost * 0.7 * pow(1.2, level - 1))

func on_sold(value:int)->void:
	GameManager.instance.player_data.add_gold(value)

# 更新技能冷却
# 功能：更新所有技能的冷却时间
# 参数：
#   delta: 帧间隔时间
func update_skills(delta: float):
	for skill_name in skills.keys():
		var skill = skills[skill_name]
		skill.cooldown = max(0, skill.cooldown - delta)

# 检查技能触发条件
# 功能：检查并触发满足条件的技能
func check_skill_triggers():
	for skill_name in skills.keys():
		var skill = skills[skill_name]
		if skill.cooldown <= 0:
			match skill.data.trigger_condition:
				"on_attack":
					if is_attacking:
						trigger_skill(skill_name)
				"on_hit":
					# 在攻击命中时触发
					pass
				"on_timer":
					# 定时触发
					trigger_skill(skill_name)
				"on_low_health":
					if current_health / get_max_health() < 0.3:
						trigger_skill(skill_name)

# 触发技能
# 功能：触发指定技能
# 参数：
#   skill_name: 技能名称
func trigger_skill(skill_name: String):
	var skill = skills[skill_name]
	if not skill or skill.cooldown > 0:
		return
	
	# 触发技能效果
	match skill.data.effect_type:
		"area_damage":
			trigger_area_damage(skill.data)
		"slow":
			trigger_slow(skill.data)
		"stun":
			# 实现眩晕效果
			pass
		"poison":
			# 实现中毒效果
			pass
	
	# 设置冷却时间
	skill.cooldown = skill.data.cooldown

# 范围伤害技能
# 功能：触发范围伤害技能
# 参数：
#   skill_data: 技能数据
func trigger_area_damage(skill_data: Dictionary):
	var area = Area3D.new()
	var shape = SphereShape3D.new()
	shape.radius = skill_data.range
	area.add_shape(shape)
	area.global_position = global_position
	add_child(area)
	
	# 检测范围内的敌人
	var enemies = area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemies"):
			enemy.take_damage(skill_data.damage)
	
	# 清理
	area.queue_free()

# 减速技能
# 功能：触发减速技能
# 参数：
#   skill_data: 技能数据
func trigger_slow(skill_data: Dictionary):
	var area = Area3D.new()
	var shape = SphereShape3D.new()
	shape.radius = skill_data.range
	area.add_shape(shape)
	area.global_position = global_position
	add_child(area)
	
	# 对范围内的敌人应用减速效果
	var enemies = area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemies"):
			enemy.apply_slow(skill_data.duration, 0.5)  # 50%减速
	
	# 清理
	area.queue_free()

# 创建攻击范围可视化
# 功能：创建并初始化攻击范围可视化组件
func create_range_visualizer():
	range_visualizer = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = get_current_range()
	mesh.height = get_current_range() * 2
	range_visualizer.mesh = mesh
	
	var material = ShaderMaterial.new()
	var shader = load("res://assets/shader/range_visualizer.gdshader")
	if shader:
		material.shader = shader
	
	range_visualizer.material_override = material
	
	add_child(range_visualizer)
	# range_visualizer.visible = false

# 显示攻击范围可视化
# 功能：显示攻击范围
func show_range_visualizer():
	if range_visualizer:
		range_visualizer.visible = true

# 隐藏攻击范围可视化
# 功能：隐藏攻击范围
func hide_range_visualizer():
	if range_visualizer:
		range_visualizer.visible = false

# 初始化Area3D节点
# 功能：设置Area3D节点的碰撞形状和范围
func initialize_area3d():
	$TriggerArea/CollisionShape3D.shape.radius = get_current_range()

# 播放升级动画
# 功能：播放升级动画和特效
func play_upgrade_animation():
	var animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("upgrade")
	
	# # 播放升级特效
	# var upgrade_effect = preload("res://effects/upgrade_effect.tscn").instantiate()
	# if upgrade_effect:
	#     upgrade_effect.global_position = global_position
	#     get_tree().get_root().add_child(upgrade_effect)
	#     upgrade_effect.lifetime = 2.0

# 进入防御塔控制
# 功能：进入防御塔的第一人称控制模式
# 参数：
#   player: 玩家控制器节点
func enter_tower_control(player: Node3D) -> void:
	is_player_controlled = true
	player_controller = player
	
	# 保存玩家状态
	player_controller.set_deferred("visible", false)
	# 禁用玩家控制
	player_controller.is_controllable = false
	
	# 创建第一人称相机
	if not first_person_camera:
		first_person_camera = Camera3D.new()
		first_person_camera.name = "FirstPersonCamera"
		first_person_camera.transform = Transform3D(Basis.IDENTITY, Vector3(0, 1.5, 0))
		add_child(first_person_camera)
	
	# 激活相机
	first_person_camera.current = true
	
	UIManager.instance.emit_event(NoteType.player_main_cross,1)

# 退出防御塔控制
# 功能：退出防御塔的第一人称控制模式
func exit_tower_control() -> void:
	is_player_controlled = false
	
	# 恢复玩家状态
	if player_controller:
		player_controller.set_deferred("visible", true)
		# 恢复玩家控制
		player_controller.is_controllable = true
		player_controller = null
	
	# 禁用相机
	if first_person_camera:
		first_person_camera.current = false
	
	UIManager.instance.emit_event(NoteType.player_main_cross,0)

# 开火逻辑
# 功能：第一人称模式下的开火逻辑
func fire():
	if attack_cooldown > 0:
		return
	
	# 检查是否有子弹场景
	var bullet_scene = preload("res://scenes/bullet.tscn")
	if not bullet_scene:
		print("Error: Bullet scene not found")
		return
	
	# 发射子弹
	var bullet = bullet_scene.instantiate()
	bullet.position = first_person_camera.global_position
	bullet.rotation = first_person_camera.global_rotation
	bullet.damage = get_current_damage()
	get_tree().get_root().add_child(bullet)
	
	# 设置攻击冷却
	attack_cooldown = get_current_attack_speed()
