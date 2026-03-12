#!/usr/bin/env bash
# install-skills.sh — 将 AI-TASK 开源 Skills 通过 symlink 注入到各 IDE 全局目录
# 用法：
#   ./install-skills.sh          # 交互式选择（默认注入已安装的 IDE）
#   ./install-skills.sh --all    # 注入全部已安装的 IDE
#   ./install-skills.sh --list   # 查看已注入状态
#   ./install-skills.sh --remove # 清理已注入的 symlink

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

# 技能列表
SKILLS=(task-review task-init)

# IDE 配置：名称 → 全局目录 → 子目录名
# 格式：ide_name:base_dir:subdir
IDE_CONFIGS=(
  "claude:$HOME/.claude/commands"
  "claude-internal:$HOME/.claude-internal/commands"
  "codebuddy:$HOME/.codebuddy/commands"
  "codex:$HOME/.codex/skills"
  "gemini:$HOME/.gemini/commands"
)

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERR]${NC} $*"; }

# 解析 IDE 配置
get_ide_name() { echo "$1" | cut -d: -f1; }
get_ide_dir()  { echo "$1" | cut -d: -f2; }

# 检测 IDE 是否已安装（基础目录存在）
is_ide_installed() {
  local dir
  dir="$(get_ide_dir "$1")"
  local base_dir
  base_dir="$(dirname "$dir")"
  [[ -d "$base_dir" ]]
}

# 获取已安装的 IDE 列表
get_installed_ides() {
  local installed=()
  for config in "${IDE_CONFIGS[@]}"; do
    if is_ide_installed "$config"; then
      installed+=("$config")
    fi
  done
  echo "${installed[@]}"
}

# 检查某个 skill 的 symlink 状态
check_skill_link() {
  local ide_dir="$1" skill="$2"
  local target="$ide_dir/$skill"
  local source="$SKILLS_DIR/$skill"

  if [[ -L "$target" ]]; then
    local actual
    actual="$(readlink "$target")"
    if [[ "$actual" == "$source" ]]; then
      echo "linked"
    else
      echo "stale"
    fi
  elif [[ -e "$target" ]]; then
    echo "conflict"
  else
    echo "missing"
  fi
}

# ---- 命令：--list ----
cmd_list() {
  info "已注入状态："
  echo ""
  local found=false
  for config in "${IDE_CONFIGS[@]}"; do
    local name dir
    name="$(get_ide_name "$config")"
    dir="$(get_ide_dir "$config")"
    local base_dir
    base_dir="$(dirname "$dir")"

    if [[ ! -d "$base_dir" ]]; then
      printf "  %-18s %s\n" "$name" "（未安装）"
      continue
    fi

    found=true
    for skill in "${SKILLS[@]}"; do
      local status
      status="$(check_skill_link "$dir" "$skill")"
      case "$status" in
        linked)   printf "  %-18s %-15s ${GREEN}✓ 已注入${NC}\n" "$name" "$skill" ;;
        stale)    printf "  %-18s %-15s ${YELLOW}⚠ 链接指向不同位置${NC}\n" "$name" "$skill" ;;
        conflict) printf "  %-18s %-15s ${RED}✗ 路径被占用（非 symlink）${NC}\n" "$name" "$skill" ;;
        missing)  printf "  %-18s %-15s ${BLUE}○ 未注入${NC}\n" "$name" "$skill" ;;
      esac
    done
  done

  if [[ "$found" == false ]]; then
    warn "未检测到已安装的 IDE"
  fi
}

# ---- 命令：注入 ----
inject_skills() {
  local configs=("$@")
  local count=0

  for config in "${configs[@]}"; do
    local name dir
    name="$(get_ide_name "$config")"
    dir="$(get_ide_dir "$config")"

    # 确保目标目录存在
    mkdir -p "$dir"

    for skill in "${SKILLS[@]}"; do
      local source="$SKILLS_DIR/$skill"
      local target="$dir/$skill"

      if [[ ! -d "$source" ]]; then
        err "技能目录不存在：$source"
        continue
      fi

      local status
      status="$(check_skill_link "$dir" "$skill")"

      case "$status" in
        linked)
          info "$name/$skill — 已是最新，跳过"
          ;;
        stale)
          warn "$name/$skill — 更新链接"
          rm "$target"
          ln -s "$source" "$target"
          ok "$name/$skill — 已更新"
          ((count++))
          ;;
        conflict)
          warn "$name/$skill — 路径被占用（非 symlink），跳过"
          warn "  手动检查：$target"
          ;;
        missing)
          ln -s "$source" "$target"
          ok "$name/$skill — 已注入"
          ((count++))
          ;;
      esac
    done
  done

  echo ""
  if [[ $count -gt 0 ]]; then
    ok "完成，共注入/更新 $count 个链接"
  else
    info "无需更新"
  fi
}

# ---- 命令：--remove ----
cmd_remove() {
  local count=0

  for config in "${IDE_CONFIGS[@]}"; do
    local name dir
    name="$(get_ide_name "$config")"
    dir="$(get_ide_dir "$config")"

    for skill in "${SKILLS[@]}"; do
      local target="$dir/$skill"
      if [[ -L "$target" ]]; then
        rm "$target"
        ok "已移除：$name/$skill"
        ((count++))
      fi
    done
  done

  echo ""
  if [[ $count -gt 0 ]]; then
    ok "完成，共移除 $count 个链接"
  else
    info "未发现已注入的 symlink"
  fi
}

# ---- 命令：交互式选择 ----
cmd_interactive() {
  local installed
  read -ra installed <<< "$(get_installed_ides)"

  if [[ ${#installed[@]} -eq 0 ]]; then
    warn "未检测到已安装的 IDE（检查 ~/.claude/ ~/.codebuddy/ 等目录）"
    exit 1
  fi

  info "检测到以下已安装的 IDE："
  echo ""
  local i=1
  for config in "${installed[@]}"; do
    local name
    name="$(get_ide_name "$config")"
    echo "  $i) $name"
    ((i++))
  done
  echo "  a) 全部"
  echo "  q) 退出"
  echo ""

  read -rp "选择要注入的 IDE（编号/a/q，多选用空格分隔）: " -a choices

  local selected=()
  for choice in "${choices[@]}"; do
    case "$choice" in
      a|A)
        selected=("${installed[@]}")
        break
        ;;
      q|Q)
        info "已取消"
        exit 0
        ;;
      *)
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#installed[@]} )); then
          selected+=("${installed[$((choice-1))]}")
        else
          warn "无效选择：$choice"
        fi
        ;;
    esac
  done

  if [[ ${#selected[@]} -eq 0 ]]; then
    warn "未选择任何 IDE"
    exit 1
  fi

  echo ""
  inject_skills "${selected[@]}"
}

# ---- 命令：--all ----
cmd_all() {
  local installed
  read -ra installed <<< "$(get_installed_ides)"

  if [[ ${#installed[@]} -eq 0 ]]; then
    warn "未检测到已安装的 IDE"
    exit 1
  fi

  info "注入到所有已安装的 IDE..."
  echo ""
  inject_skills "${installed[@]}"
}

# ---- 主入口 ----
main() {
  # 检查 skills 目录
  if [[ ! -d "$SKILLS_DIR" ]]; then
    err "技能目录不存在：$SKILLS_DIR"
    err "请在 AI-TASK 仓库根目录下运行此脚本"
    exit 1
  fi

  case "${1:-}" in
    --list)   cmd_list ;;
    --remove) cmd_remove ;;
    --all)    cmd_all ;;
    --help|-h)
      echo "用法：$(basename "$0") [--all | --list | --remove | --help]"
      echo ""
      echo "  (无参数)   交互式选择注入哪些 IDE"
      echo "  --all      注入全部已安装的 IDE"
      echo "  --list     查看已注入状态"
      echo "  --remove   清理已注入的 symlink"
      echo ""
      echo "支持的 IDE："
      for config in "${IDE_CONFIGS[@]}"; do
        local name dir
        name="$(get_ide_name "$config")"
        dir="$(get_ide_dir "$config")"
        printf "  %-18s → %s\n" "$name" "$dir"
      done
      ;;
    *)        cmd_interactive ;;
  esac
}

main "$@"
