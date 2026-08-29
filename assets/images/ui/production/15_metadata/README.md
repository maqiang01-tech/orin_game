# 《异变纪元：幸存者编队》Production Assets V1.1 Clean

本包按照最终确认的生产基线整理，目标是 Godot 4.7 可直接使用，而不是效果图硬裁图。

## 核心原则
- 设计分辨率：720×1280，竖屏 9:16。
- UI 风格：末日废土 / 黑金工业 / 磨损金属 / 暗金橙金 / 危险血红。
- 所有最终 PNG 均为独立文件，不提供运行时图集。
- CTA 仅 Normal / Hover / Pressed / Disabled 四态。
- 功能按钮为“金属边框底板 + 图案”一体资源，文字由 Godot Label 绘制。
- 底部导航直接提供 5 个完整按钮的 normal / selected / disabled 三态。
- 地图节点提供医院/超市/地铁/安全屋/未知五类 × normal/selected/danger/locked 四态。
- 窗口、面板、文本框保持空底，可拉伸资源见 nine_patch.json。
- 进度条只保留一个通用 Track + 红/蓝/金/紫/绿 Fill。
- 槽位只保留有实际视觉意义的状态，不复制完全相同的 locked/disabled。
- 5 名角色、10 张背景、设施/道具/BOSS/天赋/职业标记均为独立文件。
- 5 张页面效果图仅用于 Godot 布局对照。

## 元数据
- ui_layout_720x1280.json / csv：控件坐标
- text_positions.json：文字区域
- click_regions.json：点击热区
- button_specs.json：按钮状态与文本安全区
- nine_patch.json：NinePatchRect 边距
- page_asset_map.json：页面控件到资源文件映射
- asset_manifest.json：全部 PNG 尺寸与哈希
- duplicate_report.json：完全重复图像检查
- quality_report.json：基础质量检查

## 推荐 Godot 节点
- TextureButton：CTA / 功能按钮 / 底部导航 / 地图节点
- NinePatchRect：窗口 / 面板 / 文本框
- TextureProgressBar：状态条
- TextureRect：人物 / 背景 / 独立道具
- Label / RichTextLabel：文字


## 全图审计修正版
- 审计源：V1.1 Clean
- PNG 总数：215
- 本次重制：113 张
- 审计文件：`full_asset_audit.json` / `full_asset_audit.csv`
- 重制列表：`problem_assets_replaced.json`
- 修复重点：设施残图、角色相邻残片、窗口裁图残留、文本框残影、面板比例错误、边框只剩两侧、槽位上方残块、Badge残片、系统按钮比例错误、职业标记和防御图标可读性。
