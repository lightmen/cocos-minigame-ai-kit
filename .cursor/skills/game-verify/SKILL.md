---
name: game-verify
description: 改完代码后的标准验证：TypeScript 类型检查、core 层单测、Lint。场景和预制体改动还要走 game-mcp。任何轨道的改动收尾都要跑。
---

# game-verify — 验证

**每次改动收尾都要跑。** 验证的定义是：别人照着你写的步骤能复现同样的结果。

## 标准流程

按改动范围选择，不必每次全量：

```bash
# 任何 TS 改动
npm run typecheck

# 改了 assets/scripts/core/
npm run test

# 改动较大或新增文件。会拦截宪法违规
npm run lint

# 三件一起，工程若配置了这条脚本
npm run verify
```

工程还没有这些脚本时，用项目里实际存在的类型检查和测试命令，并在回复里写清命令。不要发明一条跑不起来的 `npm run verify`。

## 两个 typecheck 的区别

Cocos 的根 `tsconfig.json` 继承 `./temp/tsconfig.cocos.json`，而 `temp/` 由编辑器生成且不进版本库。全新克隆的仓库里，依赖根 tsconfig 的检查会失败。

日常类型检查应覆盖不依赖 `cc` 的 `core/` 和 `tests/`，这样不打开编辑器也能跑。全量检查（含 `ui/`、`game/`）需要先用 Creator 打开过一次工程。

`assets/scripts/core/` 和 `tests/` 各自需要一份 `tsconfig.json`，避免测试工具向上找到给 Cocos 用的那份。删掉它们，测试会去继承编辑器的配置。

## Lint 会拦住什么

`eslint.config.mjs` 把宪法里最容易被无意破坏的几条变成报错。模板在 `kit/eslint.config.mjs`，用 `adopt.sh --eslint` 放入还没有 ESLint 的工程。

| 规则 | 对应 |
|-|-|
| `core/` 禁止 `import 'cc'`、禁止反向依赖上层 | 原则 3 |
| `core/` 禁止 `Math.random()` / `Date.now()` / `performance.now()` | 确定性 |
| `platform/` 之外禁止 `wx` / `window` / `document` / `localStorage` | 原则 4 |
| 禁止 `find('路径/字符串')` | 原则 5 |
| 禁止 `any` 与 `@ts-` 注释 | 原则 10 |

## 按轨道的最低要求

| 轨道 | 最低验证 |
|-|-|
| Lite（不涉及 core，也不涉及场景） | 类型检查，加上改动说明里的复现步骤 |
| Lite（涉及 core） | 类型检查 + `core/` 单测 |
| Lite / Standard（改了场景、预制体或看得见的表现） | 上面的命令 + `game-mcp` |
| Standard（新规则） | 类型检查 + 单测，且新规则有对应的新测试 |
| Heavy | Standard 全套 + `game-build` 包体检查 + plan 里的真机或联调步骤 |

涉及资源或分包，追加：

```bash
bash .cursor/skills/game-build/check-size.sh
```

## 类型检查跑不过怎么办

**不要用 `as any` 或 `@ts-ignore` 让它通过。**

- `core/` 报找不到 `cc` 的类型 → `core/` 本来就不该 import `cc`，把引擎依赖挪到 `game/`
- 协议类型对不上 → 回服务端仓改源头再同步，不要手改 `net/generated/`
- 节点可能为 null → 用 `@property` 在编辑器里拖引用，或显式处理 null

## 单测写在哪

`tests/core/` 下，按 `core/` 的目录结构镜像。只测纯逻辑，不启动引擎。

每个新规则至少覆盖：正常路径、边界值（0 / 负数 / 上限）、空集合或缺省输入。

## 回复里要写什么

改了什么、跑了哪些命令、结果是什么。走了 `game-mcp` 的，写上场景名、做了什么操作、看到什么。不要只说「已验证通过」。
