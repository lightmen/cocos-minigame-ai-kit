---
name: game-asset
description: 资源与分包规范——新增的图片、音频、预制体、图集该放哪个目录、进不进主包、怎么划 Asset Bundle。当用户要加资源、加界面、调整分包、或包体超线需要挪资源时使用。
---

# game-asset — 资源落点与分包

回答一个问题：**这个资源该放哪。**

## 落点决策

```
这个资源是不是「首屏启动前必须就绪」？
├── 是 → assets/resources/    会进主包，只放极小的必需品
└── 否 → 它属于哪个玩法/界面模块？
         └── assets/bundles/<module>/   按模块划 Asset Bundle
```

`assets/resources/` 里应该只有：启动 Logo、加载界面、加载进度条的几张图、初始化必需的配置 JSON。其余进 bundles。

## Bundle 划分

按**玩法模块**划。玩家进战斗时只下载战斗资源。按贴图、音频这种类型划，进任何一个界面都要拉全量。

```
bundles/battle/      战斗场景 + 角色 + 特效 + 战斗音效
bundles/lobby/       大厅界面 + 头像框 + 背景音乐
```

公共资源（通用按钮、字体、通用音效）放 `bundles/common/`，让共享资源只打一份。

## 新增资源时写清

1. 落在哪个 bundle？为什么不是 `resources/`？
2. 预估体积增量多少？
3. 贴图是否压缩（微信小游戏优先 ASTC，兜底 ETC2）？
4. 散图能不能合进已有图集？
5. `.meta` 是否一起提交？

## 释放

加载了就要有释放路径。宪法原则 2。

```typescript
onDestroy() {
    this.bundle.release(this.spriteFrame);
}

assetManager.getBundle('battle')?.releaseAll();
```

`releaseAll()` 会释放该 bundle 的全部资源。跨 bundle 共享的资源放 `common/`，不要在业务 bundle 里释放。

## 什么时候升轨

| 改动 | 轨道 |
|-|-|
| 往已有 bundle 加几张图、替换或压缩已有资源 | Lite |
| 新建一个 Asset Bundle，或改变已有资源的 bundle 归属 | Standard |
| 重新划分分包策略、引擎分离、开放数据域 | Heavy |

动过资源就跑 `bash .cursor/skills/game-build/check-size.sh`。改了场景或预制体再走 `game-mcp`。
