# specs/

只有 Standard 和 Heavy 才在这里建目录。Lite 不建。

目录名：`specs/<NNN>-<短名>/`，编号递增。

| 文件 | 何时写 |
|---|---|
| `gdd.md` | 新玩法、新的玩家循环。由 Game Dev Studio 起草，**人确认后**放在这里，然后再写 spec |
| `spec.md` | 口径。引用 `gdd.md` 里已经确认的规则，不另起一套数字 |
| `plan.md` | 分层、顺序、可执行的验证 |
| `tasks.md` | T00x。每轮只实现被点名的一个 |
| `adr.md` | 仅 Heavy |

当前进行中的目录写在 `.specify/feature.json`。
