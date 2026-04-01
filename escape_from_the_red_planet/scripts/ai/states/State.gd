# 状态基类

class_name State

var state_name = "State"

func _init():
	# 初始化状态
	pass

func set_ai(ai_instance):
	# 设置 AI 实例
	pass

func enter_state():
	# 进入状态
	pass

func exit_state():
	# 退出状态
	pass

func process(delta):
	# 处理状态逻辑
	pass

func get_state_name():
	# 获取状态名称
	return state_name
