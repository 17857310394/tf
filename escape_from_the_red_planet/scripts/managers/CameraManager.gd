extends Node3D

# 视角类型枚举
enum CameraMode {
	BIRDS_EYE = 0,
	FIRST_PERSON = 1,
	THIRD_PERSON = 2
}

# 相机引用
var player_camera
var birds_eye_camera
var third_person_camera

# 玩家引用
var player

# 当前视角模式
var current_mode = CameraMode.FIRST_PERSON

# 鸟瞰视角参数
var birds_eye_height = 20.0
var birds_eye_rotation = Vector3(30, 0, 0)
var birds_eye_distance = 30.0

# 第三人称视角参数
var third_person_distance = 5.0
var third_person_height = 2.0
var third_person_offset = Vector3(0, third_person_height, -third_person_distance)

# 鼠标灵敏度
var mouse_sensitivity = 0.005

# 相机旋转角度
var camera_rotation = Vector3(0, 0, 0)

# 初始化
func _ready():
	# 查找玩家节点
	player = get_parent().get_node("PlayerController")
	if player:
		player_camera = player.get_node("Camera3D")
	else:
		print("Error: PlayerController not found")
	
	# 创建鸟瞰相机
	birds_eye_camera = Camera3D.new()
	birds_eye_camera.name = "BirdsEyeCamera"
	add_child(birds_eye_camera)
	
	# 创建第三人称相机
	third_person_camera = Camera3D.new()
	third_person_camera.name = "ThirdPersonCamera"
	add_child(third_person_camera)
	
	# 设置初始视角
	if player_camera and birds_eye_camera and third_person_camera:
		switch_camera_mode(current_mode)
	else:
		print("Error: Cameras not initialized properly")

# 处理输入
func _input(event):
	# 视角切换
	if event.is_action_pressed("camera_birdseye"):
		switch_camera_mode(CameraMode.BIRDS_EYE)
	elif event.is_action_pressed("camera_first_person"):
		switch_camera_mode(CameraMode.FIRST_PERSON)
	elif event.is_action_pressed("camera_third_person"):
		switch_camera_mode(CameraMode.THIRD_PERSON)
	
	# 鼠标控制
	if event is InputEventMouseMotion:
		if current_mode == CameraMode.THIRD_PERSON:
			# 第三人称视角旋转
			camera_rotation.x = clamp(camera_rotation.x - event.relative.y * mouse_sensitivity, -PI/4, PI/4)
			camera_rotation.y = camera_rotation.y - event.relative.x * mouse_sensitivity
	
	# 鼠标滚轮缩放（仅鸟瞰视角）
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if current_mode == CameraMode.BIRDS_EYE:
			birds_eye_distance = max(10, birds_eye_distance - 1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if current_mode == CameraMode.BIRDS_EYE:
			birds_eye_distance = min(50, birds_eye_distance + 1)

# 切换相机模式
func switch_camera_mode(mode):
	current_mode = mode
	
	# 禁用所有相机
	if player_camera:
		player_camera.current = false
	if birds_eye_camera:
		birds_eye_camera.current = false
	if third_person_camera:
		third_person_camera.current = false
	
	# 启用当前模式的相机
	match mode:
		CameraMode.BIRDS_EYE:
			if birds_eye_camera:
				birds_eye_camera.current = true
		CameraMode.FIRST_PERSON:
			if player_camera:
				player_camera.current = true
		CameraMode.THIRD_PERSON:
			if third_person_camera:
				third_person_camera.current = true

# 更新相机位置
func _process(_delta):
	if not player:
		return
	
	match current_mode:
		CameraMode.BIRDS_EYE:
			if birds_eye_camera:
				# 鸟瞰视角：相机位于玩家上方，仅缩放，不旋转
				# 使用固定的旋转角度（俯视图）
				# 在Godot中，x轴旋转负值表示向下看（俯视角）
				var fixed_rotation = birds_eye_rotation/180 * PI  # -转换为弧度
				# 计算相机高度
				var camera_height = birds_eye_height + birds_eye_distance
				# 计算相机平移距离，使人物在不同旋转角度下都能保持在视口中间
				# 平移距离 = 相机高度 * tan(旋转角度)
				var pitch_angle = abs(fixed_rotation.x)  # 取旋转角度的绝对值
				var forward_offset = camera_height * tan(pitch_angle)
				# 计算相机位置：在玩家上方，向前平移一定距离
				var camera_position = player.global_position + Vector3(0, camera_height, -forward_offset)
				# 设置相机变换
				birds_eye_camera.global_position = camera_position
				# 设置相机旋转为固定的俯视角
				birds_eye_camera.rotation = fixed_rotation
				# 让相机看向玩家，确保角色在相机中心位置
				birds_eye_camera.look_at(player.global_position, Vector3.UP)
		
		CameraMode.THIRD_PERSON:
			if third_person_camera:
				# 第三人称视角：相机位于玩家后方
				# 限制垂直旋转范围，避免相机反转
				var clamped_rotation_x = camera_rotation.x  # 已经在_input中限制了范围，这里直接使用
				
				# 创建旋转矩阵
				var yaw_rotation = Basis().rotated(Vector3.UP, camera_rotation.y)
				var pitch_rotation = Basis().rotated(Vector3.RIGHT, clamped_rotation_x)
				var camera_rotation_matrix = yaw_rotation * pitch_rotation
				
				# 计算相机位置
				var target_distance = third_person_distance
				var camera_offset = camera_rotation_matrix * Vector3(0, third_person_height, -target_distance)
				var camera_position = player.global_position + camera_offset
				
				# 检查相机是否低于地面，如果是，则调整距离
				var min_camera_height = 1.0  # 相机最低高度
				if camera_position.y < min_camera_height:
					# 计算需要调整的距离
					var height_diff:float = min_camera_height - camera_position.y;
					# 基于高度差调整相机距离
					var adjusted_distance:float = max(1.0, target_distance - height_diff * 2.0)
					# 重新计算相机位置
					camera_offset = camera_rotation_matrix * Vector3(0, third_person_height, -adjusted_distance)
					camera_position = player.global_position + camera_offset
					# 确保相机不会低于地面
					camera_position = Vector3(camera_position.x, max(camera_position.y, min_camera_height), camera_position.z);
				
				# 设置相机位置和旋转
				third_person_camera.global_position = camera_position
				third_person_camera.look_at(player.global_position + Vector3(0, third_person_height, 0), Vector3.UP)
