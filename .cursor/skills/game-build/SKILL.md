---
name: game-build
description: 命令行构建微信小游戏包，并做主包 4MB / 分包 30MB 的包体红线检查。当用户要出包、构建、发布微信小游戏，或改动涉及资源与分包需要确认包体时使用。
---

# game-build — 构建与包体检查

微信小游戏的硬上限是**主包 4MB、全部分包合计 30MB**。任何动资源的改动都要过一遍这里。

## 前置

```bash
cd .cursor/skills/game-build && cp local.env.example local.env
```

`local.env` 不进版本库。填本机的 Creator 可执行文件、微信 AppID、开发者工具路径。

## 构建

先在编辑器的构建发布面板配好选项，导出构建配置 JSON。之后：

```bash
source .cursor/skills/game-build/local.env

"$COCOS_CREATOR" --project "$PWD" \
  --build "configPath=./build-config/wechatgame.json"
```

还没有导出配置时，可以用：

```bash
"$COCOS_CREATOR" --project "$PWD" \
  --build "platform=wechatgame;debug=false;buildPath=project://build;packages={\"wechatgame\":{\"appid\":\"$WECHAT_APPID\"}}"
```

构建产物在 `build/wechatgame/`。

## 包体检查

```bash
bash .cursor/skills/game-build/check-size.sh
```

脚本会分别统计主包和各分包，超线直接非零退出。

```bash
du -sh build/wechatgame
du -sh build/wechatgame/subpackages/*
```

## 超线了怎么办

按这个顺序处理：

1. **主包里有不该有的资源** — 把非启动必需的从 `assets/resources/` 挪进 `assets/bundles/`。
2. **贴图没压缩** — 微信小游戏优先 ASTC / ETC2。
3. **引擎模块没裁剪** — 关掉用不到的模块。这是包体结构调整，先选轨，Heavy。
4. **引擎原生代码分包** — 构建选项里把 WASM/asm.js 移出主包。Heavy。
5. **远程资源** — 大资源走资源服务器，域名要在微信后台配成合法域名。

## 真机调试

```bash
open -a "$WECHAT_DEVTOOLS" build/wechatgame
```

开发者工具的调试基础库要在 2.1.0 以上，否则分包不生效。

## 禁止

- 手改 `build/` 下的产物。要改就改源头再重新构建。
- 把 `build/` 提交进版本库。
- 为了过包体线而删掉仍被引用的资源。
