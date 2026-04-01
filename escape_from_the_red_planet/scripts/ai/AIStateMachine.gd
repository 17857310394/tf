extends Node

# AI 状态机主脚本

# 引用
var ai_character = null  # 从父节点获取

# 状态机实现
var current_state = null
var states = {}

# 导入状态脚本
var PatrolState = preload("res://scripts/ai/states/PatrolState.gd")
var ChaseState = preload("res://scripts/ai/states/ChaseState.gd")
var AttackState = preload("res://scripts/ai/states/AttackState.gd")
var EscapeState = preload("res://scripts/ai/states/EscapeState.gd")
var IdleState = preload("res://scripts/ai/states/IdleState.gd")

# AI 属性
@export var patrol_points = [Vector3(-10, 1, 0), Vector3(10, 1, 0), Vector3(10, 1, 10), Vector3(-10, 1, 10)]
@export var chase_distance = 10.0
@export var attack_distance = 3.0
@export var escape_distance = 15.0

# 内部变量
var current_patrol_index = 0
var target = null
var state_history = []
var navigation_agent = null
var target_update_timer = 0.0
var target_update_interval = 0.5
var movement_speed = 3.0
var health = 100
var max_health = 100
var attack_damage = 25

# 处理伤害
func _on_signal_take_damage(amount):
	# 更新健康值
	health = max(0, health - amount)
	print("AI State Machine: took ", amount, " damage. Health: ", health)
	
	# 如果血量过低，进入逃跑状态
	if health < max_health * 0.3 and current_state and current_state.get_state_name() != "EscapeState":
		transition_to("EscapeState")
	if health <= 0:
		on_enemy_died()

# 处理敌人死亡
func on_enemy_died():
	print("AI State Machine: Enemy died")
	# 这里可以添加死亡相关的逻辑

# 设置目标
func set_target(new_target):
	target = new_target
	print("Target set to: ", target.name if target else "null")
	# 更新导航代理的目标位置
	if navigation_agent and target:
		navigation_agent.target_position = target.global_position


func _ready():
	# 从父节点获取 AI 角色
	ai_character = get_parent()
	if ai_character:
		print("AI character set from parent: ", ai_character.name)
		# 更新健康值为角色的健康值
		health = ai_character.get_health()
		max_health = ai_character.get_max_health()
		movement_speed = ai_character.get_movement_speed()
		attack_damage = ai_character.get_attack_damage()
		# 获取导航代理
		navigation_agent = ai_character.get_node_or_null("NavigationAgent3D")
		if navigation_agent:
			print("Navigation agent found")
		
		ai_character.signal_take_damage.connect(_on_signal_take_damage)
	
	# 初始化状态机
	_init_states()
	
	# 初始状态
	transition_to("IdleState")
	
	# 查找玩家作为目标
	find_target()

func _init_states():
	# 创建状态实例
	states["PatrolState"] = PatrolState.new()
	states["ChaseState"] = ChaseState.new()
	states["AttackState"] = AttackState.new()
	states["EscapeState"] = EscapeState.new()
	states["IdleState"] = IdleState.new()
	
	# 设置 AI 实例
	for state_name in states.keys():
		var state = states[state_name]
		if state.has_method("set_ai"):
			state.set_ai(self)

func transition_to(state_name: String):
	# 状态转换
	if states.has(state_name):
		# 退出当前状态
		if current_state:
			if current_state.has_method("exit_state"):
				current_state.exit_state()
			_on_state_exited(current_state)
		
		# 进入新状态
		current_state = states[state_name]
		if current_state.has_method("enter_state"):
			current_state.enter_state()
		_on_state_entered(current_state)
		print("Transitioned to state: ", state_name)
	else:
		print("Error: State not found: ", state_name)

func _process(delta):
	# 调用当前状态的 process 方法
	if current_state and current_state.has_method("process"):
		current_state.process(delta)
	
	# 更新目标获取计时器
	target_update_timer += delta
	if target_update_timer >= target_update_interval:
		target_update_timer = 0.0
		find_target()
	
	# 检查状态转换条件
	check_state_transitions()

func check_state_transitions():
	# 检查目标是否存在
	if not target or not is_instance_valid(target):
		find_target()
		return
	
	# 计算距离
	var distance = ai_character.global_position.distance_to(target.global_position)
	
	# 根据距离和当前状态决定转换
	if current_state:
		var state_name = current_state.get_state_name()
		match state_name:
			"IdleState":
				if distance < chase_distance:
					transition_to("ChaseState")
				elif randf() < 0.01:  # 1% 几率开始巡逻
					transition_to("PatrolState")
			"PatrolState":
				if distance < chase_distance:
					transition_to("ChaseState")
			"ChaseState":
				if distance < attack_distance:
					transition_to("AttackState")
			"AttackState":
				if distance > attack_distance:
					transition_to("ChaseState")
			"EscapeState":
				if health > max_health * 0.7:
					transition_to("IdleState")
				elif distance > escape_distance:
					transition_to("IdleState")

func find_target():
	# 检测附近的防御塔和主城
	var potential_targets = []
	
	# 1. 检测所有防御塔
	var towers = get_tree().get_nodes_in_group("tower")
	for tower in towers:
		if tower and is_instance_valid(tower):
			potential_targets.append({
				"node": tower,
				"distance": ai_character.global_position.distance_to(tower.global_position)
			})
	
	# 2. 检测主城（假设主城在"base"组中）
	var bases = get_tree().get_nodes_in_group("base")
	for base in bases:
		if base and is_instance_valid(base):
			potential_targets.append({
				"node": base,
				"distance": ai_character.global_position.distance_to(base.global_position)
			})
	
	# 3. 选择最近的目标
	if potential_targets.size() > 0:
		# 按距离排序
		potential_targets.sort_custom(func(a, b): return a.distance < b.distance)
		# 设置最近的目标
		var closest_target = potential_targets[0]
		target = closest_target.node
		print("Found target: ", target.name, " (distance: ", closest_target.distance, ")")
		# 更新导航代理的目标位置
		if navigation_agent:
			navigation_agent.target_position = target.global_position
	else:
		# 如果没有找到目标，保持当前目标
		print("No targets found")

func _on_state_entered(state):
	# 记录状态进入
	var state_name = state.get_state_name()
	state_history.append(state_name)
	print("Entered state: ", state_name)
	
	# 通知状态当前 AI 实例
	if state.has_method("set_ai"):
		state.set_ai(self)

func _on_state_exited(state):
	# 记录状态退出
	var state_name = state.get_state_name()
	print("Exited state: ", state_name)

# 获取当前状态
func get_current_state():
	return current_state

# 获取下一个巡逻点
func get_next_patrol_point():
	current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	return patrol_points[current_patrol_index]

# 获取目标
func get_target():
	return target

# 获取 AI 角色
func get_ai_character():
	return ai_character

func get_movement_speed():
	return movement_speed

# 攻击目标
func attack_target():
	if target:
		# 执行攻击
		print("AI attacks target for ", ai_character.attack_damage, " damage")
		target.take_damage(attack_damage)
