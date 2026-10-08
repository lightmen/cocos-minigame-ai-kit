# AGENTS.md — Cocos 微信小游戏 · Agent 入口

本仓库是 **Cocos Creator 3.8 开发的微信小游戏客户端**。服务端若在独立仓库，本仓只消费协议，不改协议定义。

任何 Agent 动手之前先读完这一页。硬约束在 `.specify/memory/constitution.md`。

---

## 第一条：先选轨，再动手

拿到任何任务，第一步跑 `game-route` 出选轨卡。用户只问「该怎么做」时，出卡后停下等确认。

判定从上往下，命中即停。拿不准选更重的一档。

| 轨道 | 什么时候 | 最低制品 |
|-|-|-|
| **Lite** | 修 bug、调日志、改 UI 文案、数值微调、已有组件内小逻辑、动效与布局微调 | 变更说明 + 可执行验证。**不建 `specs/`** |
| **Standard** | 新界面 / 新玩法、对接已有协议、新增 Asset Bundle、新增存档结构、需要策划口径的新规则 | `specs/<NNN>-name/` 下的 `spec.md`、`plan.md`、`tasks.md`，并更新 `.specify/feature.json` |
| **Heavy** | 引擎或渲染方案变更、包体与分包结构调整、战斗同步方案变更、客户端与服务端协议需同时改 | Standard 全套 + 同目录 `adr.md`。架构由人终审 |

**新玩法、新的玩家循环**：Standard 开工前先跑 `game-gdd`。人确认的 `gdd.md` 放进该 feature 目录，然后再写 spec。没有确认过的 GDD，不准写 spec，不准写代码。

**Lite 的硬边界**——出现任一项立刻升 Standard：

- 新增或修改网络协议字段 / 消息号
- 新增 Asset Bundle，或改变资源的 bundle 归属
- 新增本地存档字段 / 改变存档结构
- 新增一个界面或一个玩法系统
- 新增资源进 `assets/resources/`

## 第二条：新功能按任务 ID 实现

`tasks.md` 拆成 `T001`、`T002`…… **每一轮只实现被点名的那一个。**

禁止「把这个功能做完」。

## 第三条：改完必须验证

```bash
npm run verify
```

若工程还没配这条脚本，至少跑类型检查和 `core/` 单测。命令以 `game-verify` 为准。

涉及资源或包体，再跑：

```bash
bash .cursor/skills/game-build/check-size.sh
```

改了场景、预制体，或玩家看得见的表现：编辑器要开着，走 `game-mcp`。只跑类型检查不算验证。

## 入口

| 入口 | 干什么 |
|-|-|
| `.cursor/skills/game-route` | 开工选轨 |
| `.cursor/skills/game-gdd` | 新玩法：用 Game Dev Studio 写 GDD，人确认后才进 spec |
| `.cursor/skills/game-verify` | 类型检查、core 单测、Lint |
| `.cursor/skills/game-mcp` | 在打开的 Creator 里检查场景和预制体 |
| `.cursor/skills/game-build` | 构建微信小游戏包 + 包体红线 |
| `.cursor/skills/game-asset` | 资源放哪、进不进主包 |
| `.specify/memory/constitution.md` | 硬禁止，Review 对照表 |
| `.specify/templates/` | spec / plan / tasks / adr |
| `docs/ai-workflow.md` | 这套流程为什么这样分 |

## 代码分层

```
assets/scripts/
├── core/       纯 TypeScript，禁止 import 'cc'。战斗规则、数值、状态机
├── net/        协议收发。生成物在 net/generated/，禁止手改
├── platform/   微信 API。业务代码禁止直接写 wx.*
├── ui/         界面基类、弹窗、通用组件
├── game/       Cocos Component。只做输入、调用 core、渲染、生命周期
└── common/     日志、事件、对象池。不依赖引擎
assets/resources/   进主包。只放启动必需的极小资源
assets/bundles/     Asset Bundle
tests/core/         只测 core/
```

影响战斗结果的逻辑必须在 `core/`。随机通过注入的种子随机，不用 `Math.random()`。时间由外部传入，不用 `Date.now()`。

## 硬禁止

- 业务代码里出现 `wx.`、`window`、`document`、`localStorage`（`platform/` 除外）
- `core/` 里 `import 'cc'`，或使用 `Math.random()` / `Date.now()`
- `find('Canvas/UI/xxx')` 这类路径字符串查找节点
- `as any` 或 `@ts-ignore`
- 手改 `net/generated/`
- 每帧调用链里 new 对象、拼字符串、创建闭包
- 主动 `git commit` / `git push`，除非用户明确要求
- 顺手重构、顺手改格式、顺手改相邻无关代码
- 新玩法没有人确认的 GDD 就开始写 spec 或代码
- 场景或预制体改动只报类型检查通过

## 环境

- Cocos Creator **3.8**
- 主包 4MB，分包合计 30MB
- 机器路径、AppID 放在 `.cursor/skills/game-build/local.env`（不进版本库）

引擎模块裁剪、分包结构调整属于 Heavy，先选轨再动。
