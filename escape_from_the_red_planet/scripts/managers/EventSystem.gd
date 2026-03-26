class_name EventSystem extends Node

# 事件系统单例
static var instance: EventSystem

# 事件注册表，格式：{event_name: [{callback: Callable, priority: int, once: bool}]}
var event_registry: Dictionary = {}

# 节流/防抖计时器
var throttle_timers: Dictionary = {}
var debounce_timers: Dictionary = {}

# 初始化
func _ready() -> void:
	instance = self

# 注册事件监听器
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   priority: 优先级，值越大优先级越高
#   once: 是否为一次性事件
func on(event_name: String, callback: Callable, priority: int = 0, once: bool = false) -> void:
	if not event_registry.has(event_name):
		event_registry[event_name] = []
	
	# 检查是否已存在相同的回调
	for listener in event_registry[event_name]:
		if listener.callback == callback:
			return
	
	# 添加事件监听器
	event_registry[event_name].append({
		"callback": callback,
		"priority": priority,
		"once": once
	})
	
	# 按优先级排序
	event_registry[event_name].sort_custom(_compare_priority)

# 注册一次性事件监听器
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   priority: 优先级
func once(event_name: String, callback: Callable, priority: int = 0) -> void:
	on(event_name, callback, priority, true)

# 注销事件监听器
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
func off(event_name: String, callback: Callable) -> void:
	if not event_registry.has(event_name):
		return
	
	var listeners_to_remove = []
	for listener in event_registry[event_name]:
		if listener.callback == callback:
			listeners_to_remove.append(listener)
	
	for listener in listeners_to_remove:
		event_registry[event_name].erase(listener)
	
	# 如果事件没有监听器了，删除该事件
	if event_registry[event_name].is_empty():
		event_registry.erase(event_name)

# 触发事件
# 参数:
#   event_name: 事件名称
#   ...: 可变参数，传递给回调函数
func emit(event_name: String, ...args) -> void:
	if not event_registry.has(event_name):
		return
	
	# 复制监听器列表，避免在触发过程中修改列表
	var listeners = event_registry[event_name].duplicate()
	var listeners_to_remove = []
	
	for listener in listeners:
		# 构建参数数组
		var params = [event_name]
		for arg in args:
			params.append(arg)
		# 调用回调函数，传递所有参数
		listener.callback.callv(params)
		
		# 如果是一次性事件，标记为删除
		if listener.once:
			listeners_to_remove.append(listener)
	
	# 删除一次性事件
	for listener in listeners_to_remove:
		event_registry[event_name].erase(listener)
	
	# 如果事件没有监听器了，删除该事件
	if event_registry[event_name].is_empty():
		event_registry.erase(event_name)



# 节流事件（限制事件触发频率）
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   delay: 延迟时间（秒）
func throttle(event_name: String, callback: Callable, delay: float) -> void:
	var key = event_name
	
	if throttle_timers.has(key):
		return
	
	# 执行回调
	callback.call()
	
	# 设置计时器
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(func():
		throttle_timers.erase(key)
		timer.queue_free()
	)
	add_child(timer)
	timer.start()
	throttle_timers[key] = timer

# 防抖事件（延迟执行，若在延迟期间再次触发则重置延迟）
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   delay: 延迟时间（秒）
func debounce(event_name: String, callback: Callable, delay: float) -> void:
	var key = event_name
	
	# 清除之前的计时器
	if debounce_timers.has(key):
		var old_timer = debounce_timers[key]
		old_timer.stop()
		old_timer.queue_free()
		debounce_timers.erase(key)
	
	# 设置新计时器
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(func():
		callback.call()
		debounce_timers.erase(key)
		timer.queue_free()
	)
	add_child(timer)
	timer.start()
	debounce_timers[key] = timer

# 检查事件是否有监听器
# 参数:
#   event_name: 事件名称
# 返回: 是否有监听器
func has_listeners(event_name: String) -> bool:
	return event_registry.has(event_name) and not event_registry[event_name].is_empty()

# 获取事件监听器数量
# 参数:
#   event_name: 事件名称
# 返回: 监听器数量
func get_listener_count(event_name: String) -> int:
	if not event_registry.has(event_name):
		return 0
	return event_registry[event_name].size()

# 清空所有事件
func clear_all() -> void:
	# 清除所有计时器
	for timer in throttle_timers.values():
		timer.stop()
		timer.queue_free()
	for timer in debounce_timers.values():
		timer.stop()
		timer.queue_free()
	
	throttle_timers.clear()
	debounce_timers.clear()
	
	# 清空事件注册表
	event_registry.clear()

# 优先级比较函数
func _compare_priority(a, b) -> int:
	if a.priority > b.priority:
		return -1
	elif a.priority < b.priority:
		return 1
	return 0
