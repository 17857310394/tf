# UI系统使用文档

## 系统概述

本UI系统是一个基于Godot引擎的高效UI管理系统，用于创建和管理游戏中的UI面板。系统包含以下核心模块：

- **UIManager**：UI系统核心，管理所有面板的生命周期
- **PanelManager**：管理面板实例的创建、显示和隐藏
- **ResourceManager**：管理UI资源的加载和缓存
- **EventManager**：处理UI事件的注册和触发

## 快速开始

### 1. 系统设置

1. **添加UIManager到自动加载**：
   - 打开Godot编辑器
   - 进入项目设置 → 自动加载
   - 添加 `res://ui/scripts/UIManager.gd` 并设置名称为 `UIManager`

2. **创建面板目录结构**：
   ```
   ui/
   ├── panels/          # 面板预制体
   ├── scripts/         # 系统脚本
   └── resources/       # UI资源
   ```

### 2. 创建面板

1. **创建面板场景**：
   - 在 `ui/panels/` 目录下创建场景文件（如 `MainMenu.tscn`）
   - 面板场景的根节点应为 `Control` 类型
   - 添加必要的UI元素和布局

2. **创建面板脚本**：
   - 为面板场景添加脚本（如 `MainMenu.gd`）
   - 实现以下可选方法：
     - `initialize(data: Dictionary)`：初始化面板
     - `show_animation()`：显示动画
     - `hide_animation()`：隐藏动画
     - `update_data(data: Dictionary)`：更新面板数据

### 3. 使用UI系统

#### 显示面板

```gdscript
# 显示主菜单
UIManager.instance.show_panel("MainMenu")

# 显示设置面板并传入数据
var settings_data = {
    "volume": 0.8,
    "fullscreen": true
}
UIManager.instance.show_panel("Settings", settings_data)
```

#### 隐藏面板

```gdscript
# 隐藏面板（保留实例）
UIManager.instance.hide_panel("MainMenu")

# 隐藏并销毁面板
UIManager.instance.hide_panel("Settings", true)
```

#### 销毁面板

```gdscript
# 销毁面板
UIManager.instance.destroy_panel("MainMenu")
```

#### 事件处理

```gdscript
# 注册事件
UIManager.instance.register_event("game_start", _on_game_start)

# 触发事件
UIManager.instance.emit_event("volume_changed", {"volume": 0.5})

# 注销事件
UIManager.instance.unregister_event("game_start", _on_game_start)

# 事件处理函数
func _on_game_start(data: Dictionary) -> void:
    print("Game started!")
```

#### 预加载面板

```gdscript
# 预加载面板资源
UIManager.instance.preload_panels(["MainMenu", "Settings", "HUD"])
```

## 面板示例

### 主菜单面板 (MainMenu)

**功能**：游戏主菜单，包含开始游戏、设置和退出按钮。

**使用**：
```gdscript
UIManager.instance.show_panel("MainMenu")
```

### 设置面板 (Settings)

**功能**：游戏设置，包含音量调节和全屏切换。

**使用**：
```gdscript
var settings_data = {
    "volume": 0.8,
    "fullscreen": true
}
UIManager.instance.show_panel("Settings", settings_data)
```

## 系统API

### UIManager

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `create_panel(panel_name, data, parent)` | 创建面板实例 | panel_name: 面板名称<br>data: 初始化数据<br>parent: 父节点 | 面板实例 |
| `show_panel(panel_name, data)` | 显示面板 | panel_name: 面板名称<br>data: 显示数据 | void |
| `hide_panel(panel_name, destroy)` | 隐藏面板 | panel_name: 面板名称<br>destroy: 是否销毁 | void |
| `destroy_panel(panel_name)` | 销毁面板 | panel_name: 面板名称 | void |
| `get_panel(panel_name)` | 获取面板实例 | panel_name: 面板名称 | 面板实例或null |
| `has_panel(panel_name)` | 检查面板是否存在 | panel_name: 面板名称 | bool |
| `preload_panels(panel_names)` | 预加载面板资源 | panel_names: 面板名称数组 | void |
| `register_event(event_name, callback)` | 注册事件 | event_name: 事件名称<br>callback: 回调函数 | void |
| `emit_event(event_name, data)` | 触发事件 | event_name: 事件名称<br>data: 事件数据 | void |
| `unregister_event(event_name, callback)` | 注销事件 | event_name: 事件名称<br>callback: 回调函数 | void |

### PanelManager

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `create_panel_instance(panel_name, data)` | 创建面板实例 | panel_name: 面板名称<br>data: 初始化数据 | 面板实例 |
| `show_panel(panel, data)` | 显示面板 | panel: 面板实例<br>data: 显示数据 | void |
| `hide_panel(panel, destroy)` | 隐藏面板 | panel: 面板实例<br>destroy: 是否销毁 | void |
| `destroy_panel(panel)` | 销毁面板 | panel: 面板实例 | void |
| `set_panel_z_index(panel, z_index)` | 设置面板层级 | panel: 面板实例<br>z_index: 层级值 | void |

### ResourceManager

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `load_panel_prefab(panel_name)` | 加载面板预制体 | panel_name: 面板名称 | PackedScene或null |
| `preload_resources(resources)` | 预加载资源 | resources: 资源路径数组 | void |
| `release_resource(resource_path)` | 释放资源 | resource_path: 资源路径 | void |
| `clear_cache()` | 清理缓存 | 无 | void |
| `add_panel_path(panel_name, path)` | 添加面板路径映射 | panel_name: 面板名称<br>path: 面板路径 | void |

### EventManager

| 方法 | 描述 | 参数 | 返回值 |
|------|------|------|--------|
| `register_event(event_name, callback)` | 注册事件 | event_name: 事件名称<br>callback: 回调函数 | void |
| `emit_event(event_name, data)` | 触发事件 | event_name: 事件名称<br>data: 事件数据 | void |
| `unregister_event(event_name, callback)` | 注销事件 | event_name: 事件名称<br>callback: 回调函数 | void |
| `clear_events(event_name)` | 清空事件 | event_name: 事件名称（可选） | void |

## 性能优化

1. **面板缓存**：常用面板会被缓存，避免频繁创建销毁
2. **资源预加载**：使用 `preload_panels` 方法预加载面板资源
3. **事件管理**：使用信号系统减少事件监听开销
4. **内存管理**：及时销毁不再使用的面板实例

## 扩展系统

1. **添加自定义面板**：
   - 在 `ui/panels/` 目录下创建新的面板场景和脚本
   - 在 `ResourceManager.gd` 中添加面板路径映射

2. **扩展系统功能**：
   - 继承现有模块类进行扩展
   - 添加新的模块和功能

3. **主题系统**：
   - 为面板添加主题支持
   - 实现全局主题配置

## 故障排除

1. **面板无法显示**：
   - 检查面板路径是否正确
   - 确保面板场景存在
   - 检查面板脚本是否正确

2. **事件不触发**：
   - 检查事件名称是否正确
   - 确保事件已注册
   - 检查回调函数是否正确

3. **性能问题**：
   - 减少面板数量
   - 优化面板渲染
   - 使用资源预加载

## 示例代码

### 游戏主场景

```gdscript
# Game.gd
extends Node

func _ready() -> void:
    # 预加载面板
    UIManager.instance.preload_panels(["MainMenu", "Settings"])
    
    # 显示主菜单
    UIManager.instance.show_panel("MainMenu")
    
    # 注册事件
    UIManager.instance.register_event("game_start", _on_game_start)
    UIManager.instance.register_event("volume_changed", _on_volume_changed)

func _on_game_start(data: Dictionary) -> void:
    print("Game started!")
    # 开始游戏逻辑

func _on_volume_changed(data: Dictionary) -> void:
    var volume = data.get("volume", 1.0)
    print("Volume changed to: " + str(volume))
    # 更新音量
```
