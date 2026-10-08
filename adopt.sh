#!/usr/bin/env bash
# 把本模板叠到一个已有的 Cocos Creator 工程上。
# 已存在的文件默认跳过，不用 --force 不会覆盖，也不会删除目标里多出来的文件。
# 用法: ./adopt.sh /path/to/cocos-project [--force] [--eslint]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET=""
FORCE=0
ESLINT=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --eslint) ESLINT=1 ;;
    -*) echo "未知参数: $arg" >&2; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "用法: $0 /path/to/cocos-project [--force] [--eslint]" >&2
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"

if [[ ! -f "$TARGET/package.json" && ! -d "$TARGET/assets" ]]; then
  echo "目标不像 Cocos 工程（没有 package.json 或 assets/）: $TARGET" >&2
  exit 1
fi

copy_file() {
  local rel="$1"
  local src="$ROOT/$rel"
  local dst="$TARGET/$rel"
  if [[ ! -f "$src" ]]; then
    echo "模板缺少 $rel" >&2
    exit 1
  fi
  if [[ -e "$dst" && "$FORCE" -ne 1 ]]; then
    echo "跳过（已存在） $rel"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "写入 $rel"
}

copy_tree() {
  local rel="$1"
  local src="$ROOT/$rel"
  if [[ ! -d "$src" ]]; then
    echo "模板缺少目录 $rel" >&2
    exit 1
  fi
  while IFS= read -r -d '' file; do
    local relfile="${file#"$ROOT"/}"
    copy_file "$relfile"
  done < <(find "$src" -type f -print0)
}

copy_file "AGENTS.md"
copy_tree "docs"
copy_tree ".cursor"
copy_tree ".specify"
copy_tree "specs"

if [[ "$ESLINT" -eq 1 ]]; then
  if [[ -e "$TARGET/eslint.config.mjs" && "$FORCE" -ne 1 ]]; then
    echo "跳过（已存在） eslint.config.mjs"
    echo "宪法规则在模板的 kit/eslint.config.mjs，请手工并进现有配置。"
  else
    cp "$ROOT/kit/eslint.config.mjs" "$TARGET/eslint.config.mjs"
    echo "写入 eslint.config.mjs"
  fi
fi

echo
echo "完成。接下来："
echo "  1. cp .cursor/skills/game-build/local.env.example .cursor/skills/game-build/local.env"
echo "  2. 把 local.env 写进工程 .gitignore"
echo "  3. Creator 里安装 Funplay MCP，并给 Cursor 做一键配置"
echo "  4. 第一次新玩法前: npx bmad-method install   （只选 Game Dev Studio）"
