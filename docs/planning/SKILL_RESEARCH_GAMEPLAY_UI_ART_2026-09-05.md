# 玩法迭代、自适应 UI 与图像生产 Skill 调研

日期：2026-09-05。状态：选型建议，尚未安装外部 Skill、运行其脚本或修改生产流程。结论来自项目只读检查、原作者仓库、实际 SKILL.md 和部分配套资料；不是候选在本项目的实测成绩。

## 1. 项目现状与判断

- 项目配置为 Godot 4.7、720x1280、Compatibility 渲染、canvas_items 缩放。这里核对的是配置，未验证本机引擎可执行文件版本。
- 项目协调记录显示 Gate 0 r2 修复通过 C_DESIGN，随后进入用户审批；这代表设计合同通过，不能等同于完整玩法已实现或已证明好玩。
- 用户在本轮明确纠正：当前已经不做 MVP，按完整项目推进。其他窗口中第 1-3 章 MVP 的历史信息不能再作为当前执行范围。用于验证 Skill 的代表性场景只是测试取样，不构成产品范围缩减；具体章节和配队规则以当前有效设计为准。
- `scripts/systems/battle_system.gd:76` 已有可传入 rng_seed 的战斗入口。`scripts/tools/verify_project_integrity.gd:161` 已检查同种子的首行动者、一次攻击后的日志和 HP。
- 本次在 scripts 和配置范围内未找到完整的批量对局策略比较报告。现有确定性检查是可复用基础，但还不足以证明整场重放一致、策略深度或关卡平衡。
- 历史 UI 审批参考多次修正控件数量、队列位置、矩阵比例、技能面板与敌我镜像。抽看既有 `tmp/ui_capture_team_small.png`，小屏同时容纳五张角色卡、阵型、雷达图和两层操作区，值得专项测试信息密度。截图未经本轮重新运行核对，仅作历史设计证据。
- 已有 imagegen、asset-curator、切图协议与 P/S 桥接能力。主要需要补齐领域判断与实机验证，而非再增加一个调度中心。

## 2. 优先候选

| 候选及原始入口 | 建议使用者 | 能补什么 | 接入方式与限制 |
| --- | --- | --- | --- |
| [evaluating-gameplay-balance](https://github.com/abagames/agentic-gamedev-skills/blob/main/.agents/skills/evaluating-gameplay-balance/SKILL.md) | P 分析，D 采集，C 核验 | 同条件比较策略，依据遥测提出机制修复，再做配对复测 | 首选玩法评估方法；需接本项目真实战斗入口和回合制指标，仓库未提供本项目现成平衡器 |
| [implementing-gameplay-invariants](https://github.com/abagames/agentic-gamedev-skills/blob/main/.agents/skills/implementing-gameplay-invariants/SKILL.md) | P、D、C 按职责使用 | 把策划承诺转换成可测试规则，同时要求玩家能看见影响决策的状态 | 用于装配合法性、护卫/拦截、冷却与资源结算、状态提示；不能照搬动作游戏的连点判据 |
| [ui-ux-and-feedback](https://github.com/rondorkerin/gamestack/blob/main/plugins/gamestack/skills/ui-ux-and-feedback/SKILL.md) | P、C | 游戏 HUD 信息层级、认知负担、菜单流、状态反馈 | 第一优先的游戏 UI 设计候选；配套 GUIDE/CHECKLIST 按需读，社区清单里的具体阈值需按项目验证 |
| [iteration-loop](https://github.com/rondorkerin/gamestack/blob/main/plugins/gamestack/skills/iteration-loop/SKILL.md) | P 提案，S 路由，C 复核 | 参考、差异、优先级、单点修改、验证的迭代流程 | 借用实验方法；其生成和实现步骤仍分别交给 A/D，不让 P 跨角色执行 |
| [godot-ui-containers](https://github.com/thedivergentai/GD-Agentic-Skills/blob/main/skills/godot-ui-containers/SKILL.md) | D、C | 原生容器、尺寸约束、滚动区、比例约束和布局重排 | 首选引擎落地参考；示例代码需核对，不能整体复制其强制脚本体系 |
| [ai-game-art-pipeline](https://github.com/ybuild-ai/ai-game-art-pipeline-skill/blob/main/SKILL.md) | A 生产，C 视觉核验 | 复用/生成路线、角色一致性、锚点、目标尺寸预览和运行时资源交付 | 适合改造成 A 的生产判断能力；原始 YAML description 中有未引用的冒号，GitHub 显示解析错误，需修复后校验；provider_stub 不是已接通的生图 API |
| [art-direction-and-readability](https://github.com/rondorkerin/gamestack/blob/main/plugins/gamestack/skills/art-direction-and-readability/SKILL.md) | P 制定，A 遵循，C 核验 | 风格统一、轮廓、明暗、信号色、资产可读性 | 适合作为美术规范参考；作者明确标注部分案例未经完整核验，不将其视为普遍定律 |

这些是方法和工具候选，不会仅靠安装就自动形成运行、测量和修复的闭环。

## 3. 辅助候选与暂缓项

- [Impeccable](https://github.com/pbakaus/impeccable/blob/main/.agents/skills/impeccable/SKILL.md)：可借用 critique、layout、adapt、harden 的设计审查方法，当前也包含原生平台参考。不过网页 detector/live 浏览器能力不能当成 Godot 场景检测器；启动器可能下载二进制，完整安装还涉及 hooks 和资产子代理，应先做范围适配。
- [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)：适合作为字体、色彩、交互模式的检索补充；已读版本的 stack 列表没有 Godot。不能由通用应用模板主导中式末日游戏 UI，也不应替换现有 imagegen。
- [running-headless-godot](https://github.com/abagames/agentic-gamedev-skills/blob/main/.agents/skills/running-headless-godot/SKILL.md)：可参考启动、退出码和日志约定；示例主要是 Bash/XDG，需改为本机 PowerShell/Windows 路径与隔离方式。无渲染测试不能证明画面正确。
- [godot-adapt-desktop-to-mobile](https://github.com/thedivergentai/GD-Agentic-Skills/blob/main/skills/godot-adapt-desktop-to-mobile/SKILL.md)：只选安全区、触控、文本和布局内容。本项目已是竖屏移动端，不需要导入整套桌面移植、摇杆或 3D 降级功能。
- [godot-monte-carlo-balancer](https://github.com/thedivergentai/GD-Agentic-Skills/blob/main/skills/godot-monte-carlo-balancer/SKILL.md)：Rust/rayon、数据提取与校准链较重，当前先复用 Godot 战斗逻辑，避免同时维护两套计算规则。
- [develop-web-game](https://github.com/openai/skills/blob/main/skills/.curated/develop-web-game/SKILL.md)：目标是 HTML/JS 与 Playwright，可参考小步验证方法，但不是原生 Godot 的首选执行 Skill。
- 不整体引入 gamestack 的 game-design-process：它自带设计资料目录、路由和 Claude 专用前置语法，且部分能力仍在 roadmap。选择专题 Skill 即可。

## 4. 自适应 UI 的项目接入要求（建议）

P 输出具体的布局合同，A 输出可适配的资产和元数据，D 用 Godot 布局系统实现，C 在实际运行截图与交互上验收。

| 对象 | 必须定义的行为 |
| --- | --- |
| 页面骨架 | 安全区、固定区/弹性区/滚动区、最小可用高度；长屏额外空间给谁；空间不足时先收起什么 |
| 编队矩阵 | 三列等宽、三行等高、空槽与占用槽相同尺寸；敌我显示镜像与本地数据坐标分开；少于五人仍稳定 |
| 角色卡与技能区 | 布局不足时改为选择后展开详情或滚动；不无限缩小字体和点击区；技能状态变化不挤动相邻控件 |
| 字体与文本 | 明确字号档位、最大文本、换行/截断规则；状态和数值为运行时文本，长角色名、大数值、多状态不能遮挡操作 |
| 框体与按钮 | 九宫格边距、固定角、可拉伸/平铺区域、最小尺寸、内容安全区；角饰与文字不参与错误拉伸 |
| 图像 | 背景可裁切区域与焦点、头像保护区、保持比例规则；重要人脸/物品/符号不随屏幕拉长 |
| 交互 | 手机不依赖 hover；默认、按下、选中、不可用和冷却状态完整，触控反馈与实际命中区一致 |

首轮建议测试 360x640、390x844、412x915、720x1280 四档窗口及安全区模拟；这些是建议的测试尺寸，不是已测结果，也不能替代手机实机验证。每档包含短/长名字、少人/满编、大数值、多状态、弹窗与长日志。

Godot 的 Container 管理子控件位置和尺寸；NinePatchRect 可保留角部尺寸而扩展中间区域。具体实现依 [容器文档](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html)、[NinePatchRect](https://docs.godotengine.org/en/stable/classes/class_ninepatchrect.html) 和 [多分辨率文档](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) 校验。不能将 pt/dp 直接当作本项目画布像素。

## 5. A 的图像生成判断能力（建议）

1. 先确定资源用途：概念参考、背景、角色、图标、框体、按钮状态；明确最终显示尺寸与构图保护区。
2. 先查已有资源：同角色、同风格、同状态家族可复用时保留；局部缺陷优先定点编辑，不重新生成整个家族。
3. 分开记录参考角色：风格参考、布局参考、身份参考、编辑目标分别绑定文件/hash，并说明允许与禁止继承的部分。
4. 先做 cut_plan：背景/边框/图标/装饰分别产出，数值、技能名、红点和动态状态留给运行时；整页效果图用于审批表达。
5. 采用已有 imagegen 生图入口；A 的新 Skill 负责选方法、组织提示、看图和验收，不重复建立供应商 SDK。
6. 先做一个代表性组件或角色，通过实际尺寸预览后扩展家族。状态变体必须保持轮廓、中心、边框和内容区一致。
7. 确定性检查真实 alpha、尺寸、边界、九宫格边距合法性、状态覆盖和 hash；视觉检查轮廓、风格、光照、透明边污染、缩小后的识别性和拉伸结果。
8. 不把检查器通过等同于视觉通过。记录拒绝原因，如主体偏移、假透明、细节缩小不可读、边角拉花、符号相似、风格漂移；返工只改失败项。

现有 [imagegen](C:/Users/Administrator/.codex/skills/.system/imagegen/SKILL.md) 和 [asset-curator](C:/Users/Administrator/.codex/skills/asset-curator/SKILL.md) 已覆盖生成/编辑入口、视觉家族审查及部分技术检查。新增能力应接这些基础，最终资源仍按 A -> C -> B0 -> D 流转。

## 6. 首轮玩法自主迭代试验（建议）

从完整项目当前有效设计中选定代表性遭遇、同一资源快照、同一规则版本，覆盖不同职业、阵型、技能和敌人机制。先核对 Gate 0 合同与当前设计的适用范围；测试样本不限定为第 1-3 章，也不重新定义 MVP。随系统和内容推进扩充回归矩阵。

- P 先提出一个可证伪假设，例如“调整站位/技能配置能应对特定敌人，而无脑堆攻击不应通吃所有遭遇”。
- 比较固定默认配置、全输出配置、护卫续航配置、针对性配置；角色总资源与信息权限保持一致。自动战斗是产品目标，不能照搬动作游戏 Skill 的“挂机必须输”，也不能要求多点击就应更强。
- D 优先调用实际 BattleSystem，补齐整场上限、合法动作、事件导出与重放；先证明测试策略能正确使用技能，再评价游戏本身。
- 同一种子集做修改前后配对；开发集调参后用未参与调参的保留种子复核。报告样本数、胜负、回合、存活、资源浪费、技能使用与策略差异。
- 平衡结果不能只看胜率提高，也不能把所有阵容压成同胜率。检查优势是否有代价、反制是否有效、失败原因是否能被玩家理解；好玩与否保留真实试玩反馈。
- P 输出候选修改及证据，S 按现有权限路由，D/A 实施，C 比对，S 汇总。建议首轮最多两次修订，每次只处理一个主要问题，无证据改善时停止并记录原因。

## 7. 集成形式与效果比较

建议最终形成三个项目专用入口：P 的玩法实验与游戏 UI 设计、A 的资源生成判断、D/C 的 Godot 自适应实现与视觉验收。专题资料按票据加载，S 保持唯一调度者；不把所有第三方 Skill 全局常驻，也不让外部流程自行新建调度中心。

先完成来源固定、依赖与脚本审查、角色边界适配，再选一张编队/战斗界面和一组遭遇做试验。比较旧流程与新流程时固定模型/推理配置、输入、资源、视口、种子、任务范围和验收标准，记录：

- 模型输入/缓存/输出 tokens（能取得时分列）、模型调用数、生图次数、墙钟耗时。
- 首次验收通过率、用户纠正轮数、重复缺陷数、同状态视觉对比与盲测结果。
- 不能用脚本耗时代替模型费用，也不能在没有配对数据前宣称节省百分比。

本轮结论：优先落地游戏 UI 方法、自适应合同和 A 的图像判断，再用现有带种子的战斗入口补起玩法实验。各项能力可并入现有窗口，不需要新增常驻窗口。

## 8. 核对过的上游版本

以下是调研时 GitHub API 返回的分支快照，后续安装应固定版本并保留许可证。本轮未执行其安装器、二进制或 hooks，未验证全部配套脚本。

| 仓库 | 核对快照 | API 标识的许可证 |
| --- | --- | --- |
| abagames/agentic-gamedev-skills | `9ad6a310c66f707405f23f5771e8b4bd139c7e62` | MIT |
| rondorkerin/gamestack | `0419358df31455e63820bdd89f3c5b446665f604` | MIT |
| pbakaus/impeccable | `46ffe5caa2ce5a4ca34bfe9d610a938253b151ed` | Apache-2.0 |
| nextlevelbuilder/ui-ux-pro-max-skill | `f3ac195224eac1eb0dfe1a3059c2a6add78ffbe3` | MIT |
| thedivergentai/GD-Agentic-Skills | `6a36f189d9c9b53b8c6769fb5c2cce8bfa5ad35c` | LGPL-3.0 |
| ybuild-ai/ai-game-art-pipeline-skill | `ed4a2ce1a94370d5962c7d079cd9404a863e02c7` | MIT |
