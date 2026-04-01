extends "./State.gd"

# 攻击状态

var ai = null
var attack_timer = 0.0
var attack_cooldown = 1.0

func _init():
	state_name = "AttackState"

func set_ai(ai_instance):
	ai = ai_instance

func _ready():
	# 状态就绪
	print("AttackState ready")

func enter_state():
	# 进入状态
	print("Starting attack")
	attack_timer = 0.0

func exit_state():
	# 退出状态
	print("Stopping attack")

func process(delta):
	# 处理攻击逻辑
	if not ai or not ai.get_ai_character() or not ai.get_target() or not is_instance_valid(ai.get_target()):
		return
	
	var character = ai.get_ai_character()
	var target = ai.get_target()
	var navigation_agent = character.get_node_or_null("NavigationAgent3D")
	
	# 保持在攻击距离内
	var distance = character.global_position.distance_to(target.global_position)
	if distance > ai.attack_distance:
		# 向目标移动
		if navigation_agent:
			# 更新导航代理的目标位置
			navigation_agent.target_position = target.global_position
			
			# 检查是否到达目标
			if not navigation_agent.is_navigation_finished():
				# 获取下一个路径点
				var next_path_position = navigation_agent.get_next_path_position()
				# 向路径点移动
				var direction = character.global_position.direction_to(next_path_position)
				character.velocity = direction * ai.get_movement_speed()
				character.move_and_slide()
		else:
			# 如果没有导航代理，使用直接移动
			var direction = character.global_position.direction_to(target.global_position)
			character.velocity = direction * ai.get_movement_speed()
			character.move_and_slide()
	else:
		# 停止移动，准备攻击
		character.velocity = Vector3.ZERO
		
		# 攻击冷却
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			# 执行攻击
			attack()
			attack_timer = 0.0
	
	# 打印攻击信息
	print("Attacking target, distance: ", distance)

func attack():
	ai.attack_target()
	
