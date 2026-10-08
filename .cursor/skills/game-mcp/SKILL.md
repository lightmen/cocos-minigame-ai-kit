---
name: game-mcp
description: 用 Cocos Creator 里的 Funplay MCP 检查场景、预制体和玩家看得见的表现。改了 .scene、.prefab、UI 或动效时使用；类型检查代替不了这一步。
---

# game-mcp — 在编辑器里验证

场景、预制体和看得见的表现，用已经打开该工程的 Cocos Creator 检查。类型检查看不到节点丢了、引用断了、按钮点了没反应。

编辑器侧用 [Funplay MCP for Cocos](https://github.com/FunplayAI/funplay-cocos-mcp)（Cocos Store 也可装）。它跑在编辑器里，不进游戏包。

## 一次安装

1. 用 Cocos Creator 3.8 打开本工程。
2. 菜单 **Funplay > MCP Settings**，点 **Install for All Projects**。同一台机器、同一个 Creator 版本装一次即可。
3. 打开 **Funplay > MCP Server**，对 Cursor 做一键配置。端口以面板上的地址为准，新工程通常落在 `20000–29999`，不要写死 `8765`。
4. 连通性：调用 `get_project_info`，返回的工程路径必须是当前仓库。不是就停下，不要改另一个工程。

一键配置失败时，按面板上的 URL 写入 Cursor 的 MCP 配置：

```json
{
  "mcpServers": {
    "funplay_cocos": {
      "url": "http://127.0.0.1:<面板上的端口>/"
    }
  }
}
```

## 什么时候必须跑

改动碰到下面任一处：

- `*.scene`、`*.prefab`
- 玩家看得见的 UI、按钮、动效、镜头
- `@property` 引用、节点层级、组件挂载

只改 `core/` 且没有表现变化时，不必跑。

## 检查步骤

编辑器保持打开，并且打开的是本工程。

1. `get_project_info` 确认工程。
2. `open_scene` 打开 plan 或改动说明里写的那个场景。
3. 场景用 `validate_scene`，再 `get_hierarchy` 或 `get_scene_info` 看改过的节点在不在。
4. 预制体用 `inspect_prefab` 和 `validate_prefab_references`，确认引用没有丢。
5. `capture_scene_screenshot` 留下改动后的画面。需要看运行结果时，用编辑器预览，再 `capture_preview_screenshot`。
6. 交互改动要在预览里走到那一步（例如点确定按钮），把「做了什么、看到什么」写进回复。

MCP 没连上、编辑器没开、场景打不开：验证就是未完成。不要改口说类型检查已经够了。

## 允许和禁止

默认可做：读取工程和场景、打开场景、检查预制体引用、跑脚本诊断、截图、在预览里点击以完成验证。

没有用户当次明确同意，禁止：

- `delete_node`、`delete_asset`，以及任何删除资源或节点的调用
- 通过 MCP 改写脚本或场景来「顺便修好」验证中发现的问题——先汇报，再按选轨改
- 关闭 `execute_javascript` 的安全检查（`safety_checks: false`）
- 对不是当前仓库的工程调用工具

`execute_javascript` 只在现成工具不够用时使用，例如读一个现成工具没有返回的字段。优先用上面列出的只读检查。
