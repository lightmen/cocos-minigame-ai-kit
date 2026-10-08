# Cocos 微信小游戏 · AI 开发流程模板

这不是 Cocos 工程。它是一套叠到**已有 Cocos Creator 3.8 微信小游戏工程**上的流程文件：三轨分流、宪法、新玩法开工前的 GDD、场景和预制体的编辑器验证。

下一个项目不用重写流程。在 Cocos 工程根目录执行：

```bash
/path/to/cocos-minigame-ai-kit/adopt.sh .
```

已存在的同名文件会跳过。覆盖用 `--force`。工程还没有 ESLint 时，加上 `--eslint`，会放入把宪法翻译成报错的 `eslint.config.mjs`。

## 叠进去之后

1. 填 `.cursor/skills/game-build/local.env`（从 `local.env.example` 复制）。机器路径和 AppID 不进版本库。
2. 在工程 `.gitignore` 追加：

   ```
   .cursor/skills/game-build/local.env
   ```

3. 用 Cocos Creator 打开工程，菜单 **Funplay > MCP Settings > Install for All Projects** 装一次编辑器 MCP，再在 **Funplay > MCP Server** 里给 Cursor 做一键配置。端口以面板显示的为准。
4. 第一次做新玩法之前，在工程根目录执行 `npx bmad-method install`，只选 **Game Dev Studio**。

## 三条怎么配合

| 什么时候 | 用什么 |
|---|---|
| 任何改动 | `game-route` 出选轨卡。Lite 不建 `specs/`。Standard / Heavy 按 T00x 一次做一个 |
| 新玩法、新的玩家循环 | 先 `game-gdd`，人确认 `specs/<NNN>-name/gdd.md`，再写 spec |
| 改了场景、预制体或玩家看得见的表现 | `game-verify` 之外再走 `game-mcp`，在打开的编辑器里点到 |

细则在 `AGENTS.md` 和 `docs/ai-workflow.md`。
