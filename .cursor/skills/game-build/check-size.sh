#!/usr/bin/env bash
# 微信小游戏包体红线检查：主包 4MB、全部分包合计 30MB。
# 用法：bash .cursor/skills/game-build/check-size.sh [构建产物目录]

set -euo pipefail

BUILD_DIR="${1:-build/wechatgame}"
MAIN_LIMIT_KB=$((4 * 1024))
SUB_TOTAL_LIMIT_KB=$((30 * 1024))

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "找不到构建产物目录：$BUILD_DIR"
  echo "先跑一次构建，或把产物目录作为第一个参数传入。"
  exit 1
fi

kb_of() { du -sk "$1" 2>/dev/null | awk '{print $1}'; }
fmt() { awk -v kb="$1" 'BEGIN { printf "%.2f MB", kb / 1024 }'; }

TOTAL_KB=$(kb_of "$BUILD_DIR")
SUB_DIR="$BUILD_DIR/subpackages"

SUB_TOTAL_KB=0
if [[ -d "$SUB_DIR" ]]; then
  SUB_TOTAL_KB=$(kb_of "$SUB_DIR")
fi

MAIN_KB=$((TOTAL_KB - SUB_TOTAL_KB))
FAILED=0

echo "=== 包体检查：$BUILD_DIR ==="
printf '主包        %12s  (上限 4.00 MB)\n' "$(fmt "$MAIN_KB")"
printf '分包合计    %12s  (上限 30.00 MB)\n' "$(fmt "$SUB_TOTAL_KB")"
printf '总计        %12s\n' "$(fmt "$TOTAL_KB")"

if [[ -d "$SUB_DIR" ]]; then
  echo
  echo "--- 各分包 ---"
  for pkg in "$SUB_DIR"/*/; do
    [[ -d "$pkg" ]] || continue
    printf '  %-28s %12s\n' "$(basename "$pkg")" "$(fmt "$(kb_of "$pkg")")"
  done
fi

echo
if (( MAIN_KB > MAIN_LIMIT_KB )); then
  echo "❌ 主包超出 4MB 上限，超出 $(fmt $((MAIN_KB - MAIN_LIMIT_KB)))"
  echo "   主包内最大的文件："
  find "$BUILD_DIR" -type f -not -path "$SUB_DIR/*" -exec du -k {} + 2>/dev/null \
    | sort -rn | head -15 \
    | awk '{ size=$1; $1=""; sub(/^ /, ""); printf "     %8.2f MB  %s\n", size/1024, $0 }' || true
  FAILED=1
else
  echo "✅ 主包 $(fmt "$MAIN_KB") / 4.00 MB"
fi

if (( SUB_TOTAL_KB > SUB_TOTAL_LIMIT_KB )); then
  echo "❌ 分包合计超出 30MB 上限，超出 $(fmt $((SUB_TOTAL_KB - SUB_TOTAL_LIMIT_KB)))"
  FAILED=1
else
  echo "✅ 分包合计 $(fmt "$SUB_TOTAL_KB") / 30.00 MB"
fi

if (( FAILED )); then
  echo
  echo "处理顺序见 .cursor/skills/game-build/SKILL.md：挪出 resources → 压缩贴图 → 裁剪引擎模块 → 引擎分包 → 远程资源。"
  echo "注意：改分包划分或引擎裁剪属于 Heavy 轨道，先跑 game-route 选轨。"
fi

exit $FAILED
