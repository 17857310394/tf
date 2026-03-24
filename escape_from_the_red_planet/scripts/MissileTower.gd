# MissileTower.gd
# 导弹塔实现类
# 高伤害，追踪能力，发射导弹，具有追踪效果，攻击地面和空中敌人，导弹命中后产生小范围爆炸

class_name MissileTower extends "res://scripts/BaseTower.gd"

# 导弹场景路径
var missile_scene = null #preload("res://scenes/missile.tscn")

# 攻击方法
# 功能：执行导弹塔的攻击逻辑，发射追踪导弹
func attack():
    if not target:
        return
    
    is_attacking = true
    emit_signal("on_attack_started")
    
    # 发射导弹
    var missile = missile_scene.instantiate()
    missile.position = global_position + Vector3(0, 1.5, 0)  # 从塔的顶部发射
    missile.target = target
    missile.damage = get_current_damage()
    get_tree().get_root().add_child(missile)
    
    # 设置攻击冷却
    attack_cooldown = get_current_attack_speed()
    
    # 旋转塔朝向目标
    look_at(target.global_position, Vector3.UP)
    
    is_attacking = false
    emit_signal("on_attack_completed")
