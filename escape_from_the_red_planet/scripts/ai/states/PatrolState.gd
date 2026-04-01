extends "./State.gd"

# 巡逻状态

var ai = null
var target_patrol_point = null
var patrol_timer = 0.0
var patrol_wait_time = 2.0
var is_waiting = false

func _init():
	state_name = "PatrolState"

func set_ai(ai_instance):
	ai = ai_instance

func _ready():
	# 状态就绪
	print("PatrolState ready")

func enter_state():
	# 进入状态
	print("Starting patrol")
	# 获取第一个巡逻点
	target_patrol_point = ai.get_next_patrol_point()
	print("Patrolling to: ", target_patrol_point)
	is_waiting = false
	patrol_timer = 0.0

func exit_state():
	# 退出状态
	print("Stopping patrol")

func process(delta):
	# 处理巡逻逻辑
	if not ai or not ai.get_ai_character():
		return
	
	var character = ai.get_ai_character()
	var navigation_agent = character.get_node_or_null("NavigationAgent3D")
	
	if is_waiting:
		# 等待一段时间
		patrol_timer += delta
		if patrol_timer >= patrol_wait_time:
			is_waiting = false
			patrol_timer = 0.0
			target_patrol_point = ai.get_next_patrol_point()
			print("Patrolling to next point: ", target_patrol_point)
			# 更新导航代理的目标位置
			if navigation_agent:
				navigation_agent.target_position = target_patrol_point
	else:
		# 使用导航代理移动到巡逻点
		if navigation_agent:
			# 检查是否到达目标
			if navigation_agent.is_navigation_finished():
				# 到达巡逻点，开始等待
				print("Reached patrol point, waiting...")
				is_waiting = true
				patrol_timer = 0.0
			else:
				# 获取下一个路径点
				var next_path_position = navigation_agent.get_next_path_position()
				# 向路径点移动
				var direction = character.global_position.direction_to(next_path_position)
				character.velocity = direction * ai.get_movement_speed()
				character.move_and_slide()
		else:
			# 如果没有导航代理，使用直接移动
			var distance = character.global_position.distance_to(target_patrol_point)
			if distance < 0.5:
				# 到达巡逻点，开始等待
				print("Reached patrol point, waiting...")
				is_waiting = true
				patrol_timer = 0.0
			else:
				# 向巡逻点移动
				var direction = character.global_position.direction_to(target_patrol_point)
				character.velocity = direction * ai.get_movement_speed()
				character.move_and_slide()
