# Cocos 微信小游戏 · AI 开发流程

这套流程做四件事：用 Lite / Standard / Heavy 决定要不要写 spec；用宪法钉死硬禁止；新玩法先有人确认的 GDD；场景和预制体在编辑器里验收。

## 1. 分流

从上往下，命中即停。拿不准选更重一档。

| 轨道 | 何时 | 最低制品 |
|-|-|-|
| Lite | 修 bug、日志、文案、调一个已有常量、已有组件内小改 | 变更说明 + 验证。不建 `specs/` |
| Standard | 新界面、新玩法、对接已有协议、新增 Bundle、新增存档、要策划口径的新规则 | `specs/<NNN>-name/` 的 spec + plan + tasks |
| Heavy | 引擎或渲染方案变更、包体结构调整、战斗同步方案变更、协议要和服务端一起改 | Standard 全套 + `adr.md`，架构由人终审 |

Lite 里一旦要动协议、新建 Bundle、改存档、新界面、新玩法、或把资源放进 `assets/resources/`，立刻停下来升轨。

Standard / Heavy 按 `tasks.md` 的任务 ID 做，每轮只做一个。

## 2. 新玩法先写 GDD

新玩法、新的玩家循环，选轨之后先走 `game-gdd`：

1. 工程里还没有 Game Dev Studio 时，用户执行 `npx bmad-method install`，只选 Game Dev Studio。
2. 用安装后的 `/bmgd-gdd` 起草。数值由人定。
3. 用户明确确认后，把 `gdd.md` 放进 `specs/<NNN>-name/gdd.md`。
4. 再写 spec。spec 的口径和 GDD 不一致就停下问人。

Game Dev Studio 不写 Cocos 脚本，不改场景，不改协议。实现仍按 T00x。

修 bug 和调已有常量不写 GDD。

## 3. 改完怎么验证

| 改了什么 | 怎么验 |
|-|-|
| TypeScript | `npm run typecheck` |
| `core/` 规则 | `npm run test`，新规则要有新测试 |
| 资源或分包 | `bash .cursor/skills/game-build/check-size.sh` |
| 场景、预制体、看得见的表现 | `game-mcp`：编辑器开着本工程，打开对应场景，检查节点和预制体引用，截图或在预览里走一遍 |

类型检查通过，不能代替编辑器里的那一步。

## 4. 四种开口

**按钮点了没反应。** Lite。改组件，类型检查，再用 `game-mcp` 打开那个场景点一次。不建 `specs/`。

**把一个已有伤害系数从 1.5 调到 1.8。** Lite。改 `core/` 里的常量，更新断言了旧值的单测。改公式结构或加新的修正项，就变成要策划口径，至少 Standard。

**加一个新的战斗玩法。** Standard，而且是新玩法。先 GDD，人确认后再写 spec、plan、tasks。实现时只点名一个任务，例如「实现 T001」。下一轮再点下一个。

**战斗要改成帧同步，协议和服务端一起动。** Heavy。spec / plan / tasks 之外补 `adr.md`，人做架构终审，再按任务实现。plan 里写清两端怎么联调。

## 5. 宪法里不能让步的几条

- 主包 4MB，分包合计 30MB。`assets/resources/` 只放启动必需的极小资源。
- 影响战斗结果的规则在 `core/`，禁止 `import 'cc'`。
- `platform/` 以外不出现 `wx.` / `window.`。
- 节点用 `@property`，不用路径字符串 `find`。
- `net/generated/` 不手改。
- `update` 调用链里不分配临时对象。
- 场景和预制体改动要在编辑器里验到。

能自动拦的几条在 `kit/eslint.config.mjs`。拦不住的（生成物手改、顺手重构、手感）靠 Review。

Review 顺序：轨道对不对（新玩法有没有确认过的 GDD）→ 宪法破了没有 → plan 的验证能不能照着做 → 最后才是手感，这一层必须人看。
