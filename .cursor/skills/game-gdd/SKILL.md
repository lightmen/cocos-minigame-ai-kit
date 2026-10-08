---
name: game-gdd
description: 新玩法或新的玩家循环开工前，用 BMAD Game Dev Studio 写 GDD，等人确认后再进入 spec。当选轨结果是新玩法、新战斗循环、新关卡规则时使用。
---

# game-gdd — 新玩法先写 GDD

新玩法、新的玩家循环，在 `spec.md` 之前要有一份**人确认过**的游戏设计文档。设计文档用 [BMAD Game Dev Studio](https://github.com/bmad-code-org/bmad-module-game-dev-studio) 起草。Cocos 实现仍走本仓库的 spec → plan → tasks。

修 bug、改文案、调一个已有常量，不要跑这个技能。

## 一次安装

工程里还没有 Game Dev Studio 时，请用户在工程根目录执行：

```bash
npx bmad-method install
```

只选 **Game Dev Studio**。不要顺便装主方法模块，除非用户明确要。安装会往工程里写 `_bmad/` 等文件，先告诉用户再执行，不要擅自安装。

官方入口（以安装后的技能说明为准）：

```
/bmgd-gdd
```

当前上游技能名是 `gds-gdd`。菜单名或斜杠命令若和这里不一致，以安装进工程的那份 `SKILL.md` 为准，不要猜一个旧命令硬跑。

## 起草

1. 让用户启动 GDD 流程，说明这次要设计的玩法，一句话就够。
2. 流程会追问支柱、操作、胜负、数值和进度。**数字由人定。** Agent 可以列选项，不能把没确认的数值写进最终稿。
3. 流程把 `gdd.md` 写到它自己的输出目录（常见是 `_bmad-output/` 下）。找到这次实际写出的 `gdd.md`，不要假设固定路径。
4. 请用户通读并明确说「GDD 确认」。没这句话，状态就是草稿。

## 确认之后

1. 建 `specs/<NNN>-<短名>/`，把确认稿复制为 `gdd.md`。
2. 更新 `.specify/feature.json` 指向这个目录，`track` 填 Standard 或 Heavy。
3. 按 `.specify/templates/spec-template.md` 写 `spec.md`。规则口径引用 `gdd.md`，不另写一套数字。两边不一致就停下问人。
4. 然后才是 plan 和 tasks。

## Game Dev Studio 不负责的事

- 不写 Cocos 脚本、不改场景、不改预制体、不改协议。
- 不用 `/bmgd-quick-dev` 跳过 GDD 直接把新玩法做出来。
- 不把 GDD 里的史诗清单当成可以一次做完的任务。实现粒度以本仓库 `tasks.md` 的 T00x 为准，每轮只做一个。

## 回复里要写什么

GDD 路径、用户是否已经确认、与 spec 口径是否一致。草稿阶段明确写「尚未确认，还不能写 spec」。
