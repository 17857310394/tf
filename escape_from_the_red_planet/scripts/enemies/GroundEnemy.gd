extends "./Enemy.gd"

func _ready():
	super()

func _physics_process(delta):
	super(delta)
	

func _die():
	is_dead = true
	print("Ground enemy died")
	# 这里可以添加死亡动画和特效
	# 延迟后删除敌人
	queue_free()
