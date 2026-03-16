#!/bin/bash
# =====================================================
# AI-TASK 软链接重建脚本 v3.0.0
# =====================================================
# 用法:
#   ./relink.sh            # 重建所有软链接（local 化命名）
#   ./relink.sh --dry-run  # 预览，不实际操作
#   ./relink.sh --check    # 只检查当前软链接状态
#   ./relink.sh --migrate  # 将旧命名 (ai-task, AGENT.md) 迁移为 local 化命名
#
# v3.0.0 变更：
#   - 软链接 local 化命名：ai-task → ai-task.local, AGENT.md → AGENT.local.md
#   - 参考 Claude Code CLAUDE.local.md 机制，.local 后缀 = "本地个人文件，不提交"
#   - 配合全局 gitignore (*.local.md + ai-task.local) 彻底消除 .gitignore 配置负担
#   - --migrate 参数支持从旧命名平滑迁移
#   - CLAUDE.md 软链接自动命名为 CLAUDE.local.md（与 Claude Code 原生对齐）
#
# 跨设备复用：脚本自动以自身所在目录作为 AI-TASK 根目录，
# 无需修改路径，copy 到新设备直接运行即可。
# =====================================================

set -e

# ---------- 颜色 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- 路径（动态，跨设备复用）----------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_TASK_ROOT="$SCRIPT_DIR"
PROJECTS_DIR="$AI_TASK_ROOT/projects"

# ---------- IDE 入口文件列表 ----------
# vault 中的源文件名 → 工作仓库中的 local 化软链接名
# 格式: "源文件名:软链接名"
declare -a IDE_ENTRY_MAP=(
  "AGENT.md:AGENT.local.md"
  "CLAUDE.md:CLAUDE.local.md"
  "CODEBUDDY.md:CODEBUDDY.local.md"
)

# ---------- 旧命名映射（用于 --migrate）----------
declare -a LEGACY_NAMES=(
  "ai-task:ai-task.local"
  "AGENT.md:AGENT.local.md"
  "CLAUDE.md:CLAUDE.local.md"
  "CODEBUDDY.md:CODEBUDDY.local.md"
)

# ---------- 参数解析 ----------
DRY_RUN=false
CHECK_ONLY=false
MIGRATE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --check)   CHECK_ONLY=true ;;
    --migrate) MIGRATE=true ;;
  esac
done

# ---------- 软链接映射表 ----------
# ⚠️  此数组为空 —— 请在 relink.local.sh 中配置你的项目映射
#
# 格式: "项目代号|代码仓库绝对路径"
# 示例:
#   declare -a LINK_MAP=(
#     "MYAPP|$HOME/Projects/my-app"
#     "DEMO|$HOME/Projects/demo"
#   )
#
# 创建方法: 复制下方模板到 relink.local.sh 并填写你的项目
declare -a LINK_MAP=()

# ---------- 加载本地配置 ----------
LOCAL_CONFIG="$SCRIPT_DIR/relink.local.sh"
if [[ -f "$LOCAL_CONFIG" ]]; then
    source "$LOCAL_CONFIG"
    echo -e "${GREEN}已加载本地配置: $LOCAL_CONFIG${NC}"
else
    echo -e "${YELLOW}提示: 未找到 relink.local.sh${NC}"
    echo -e "${YELLOW}  创建方法: cp relink.local.sh.example relink.local.sh${NC}"
    echo -e "${YELLOW}  然后编辑 LINK_MAP 数组添加你的项目映射${NC}"
    echo ""
    if [[ "$CHECK_ONLY" != "true" ]]; then
        echo -e "${RED}错误: LINK_MAP 为空，请先配置 relink.local.sh${NC}"
        exit 1
    fi
fi

# ---------- 统计 ----------
count_ok=0
count_skip=0
count_broken=0
count_relinked=0
count_migrated=0

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE} AI-TASK 软链接重建脚本 v3.0.0${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "AI-TASK 根目录: ${CYAN}$AI_TASK_ROOT${NC}"
$DRY_RUN   && echo -e "${YELLOW}[DRY-RUN 模式] 不会实际修改任何文件${NC}"
$CHECK_ONLY && echo -e "${CYAN}[CHECK 模式] 只检查状态，不修改${NC}"
$MIGRATE   && echo -e "${YELLOW}[MIGRATE 模式] 将旧命名迁移为 local 化命名${NC}"
echo ""

# ---------- 通用软链接处理函数 ----------
# 参数: $1=项目代号 $2=链接路径 $3=目标路径 $4=描述标签(可选)
handle_symlink() {
  local project_code="$1"
  local link_path="$2"
  local target="$3"
  local label="${4:-}"
  local display_name="${label:+$label }$project_code"

  # 软链接已存在且指向正确 → 无需操作
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo -e "  ${GREEN}OK${NC}    $display_name  →  $link_path"
    ((count_ok++)) || true
    return
  fi

  # CHECK 模式：只报告，不修改
  if $CHECK_ONLY; then
    if [ -L "$link_path" ]; then
      local old_target
      old_target="$(readlink "$link_path")"
      echo -e "  ${RED}STALE${NC} $display_name  →  $link_path"
      echo -e "         当前指向: $old_target"
      echo -e "         应指向:   $target"
    else
      echo -e "  ${RED}MISS${NC}  $display_name  →  $link_path  (软链接缺失)"
    fi
    ((count_broken++)) || true
    return
  fi

  # DRY-RUN 模式：打印将要执行的命令
  if $DRY_RUN; then
    if [ -L "$link_path" ]; then
      echo -e "  ${YELLOW}WOULD${NC} rm \"$link_path\""
    fi
    echo -e "  ${YELLOW}WOULD${NC} ln -s \"$target\" \"$link_path\""
    ((count_relinked++)) || true
    return
  fi

  # 实际重建
  [ -L "$link_path" ] && rm "$link_path"
  ln -s "$target" "$link_path"
  echo -e "  ${GREEN}RELINK${NC} $display_name  →  $link_path"
  ((count_relinked++)) || true
}

# ---------- 旧链接迁移函数 ----------
# 参数: $1=仓库路径 $2=旧名称 $3=新名称
migrate_link() {
  local repo_path="$1"
  local old_name="$2"
  local new_name="$3"
  local old_path="$repo_path/$old_name"
  local new_path="$repo_path/$new_name"

  if [ -L "$old_path" ]; then
    local target
    target="$(readlink "$old_path")"

    if $DRY_RUN; then
      echo -e "  ${YELLOW}WOULD MIGRATE${NC} $old_name → $new_name"
      echo -e "         target: $target"
      ((count_migrated++)) || true
      return
    fi

    rm "$old_path"
    ln -s "$target" "$new_path"
    echo -e "  ${GREEN}MIGRATE${NC} $old_name → $new_name"
    ((count_migrated++)) || true
  fi
}

# ---------- 检查/重建 ----------
for entry in "${LINK_MAP[@]}"; do
  PROJECT_CODE="${entry%%|*}"
  REPO_PATH="${entry##*|}"
  TARGET="$PROJECTS_DIR/$PROJECT_CODE"

  # 代码仓库不存在 → 本设备没有此项目，跳过
  if [ ! -d "$REPO_PATH" ]; then
    echo -e "  ${YELLOW}SKIP${NC}  $PROJECT_CODE  →  $REPO_PATH  (目录不存在，本设备无此项目)"
    ((count_skip++)) || true
    continue
  fi

  # 目标 project 目录不存在 → AI-TASK 里没有此项目，警告
  if [ ! -d "$TARGET" ]; then
    echo -e "  ${RED}WARN${NC}  $PROJECT_CODE  →  projects/$PROJECT_CODE 不存在，请先创建项目"
    ((count_broken++)) || true
    continue
  fi

  # --- 迁移旧链接 ---
  if $MIGRATE; then
    echo -e "${CYAN}[$PROJECT_CODE]${NC} 检查旧链接..."
    for legacy in "${LEGACY_NAMES[@]}"; do
      old_name="${legacy%%:*}"
      new_name="${legacy##*:}"
      migrate_link "$REPO_PATH" "$old_name" "$new_name"
    done
  fi

  # --- ai-task.local 目录软链接 ---
  handle_symlink "$PROJECT_CODE" "$REPO_PATH/ai-task.local" "$TARGET" "[dir]"

  # --- IDE 入口文件软链接 (local 化命名) ---
  for ide_entry in "${IDE_ENTRY_MAP[@]}"; do
    src_name="${ide_entry%%:*}"
    link_name="${ide_entry##*:}"
    local_file="$TARGET/$src_name"
    if [ -f "$local_file" ]; then
      handle_symlink "$PROJECT_CODE" "$REPO_PATH/$link_name" "$local_file" "[${src_name%.md}]"
    fi
  done
done

# ---------- 汇总 ----------
echo ""
echo -e "${BLUE}=====================================${NC}"
if $CHECK_ONLY; then
  echo -e " 正常: ${GREEN}$count_ok${NC}  异常: ${RED}$count_broken${NC}  跳过: ${YELLOW}$count_skip${NC}"
elif $DRY_RUN; then
  echo -e " 将重建: ${YELLOW}$count_relinked${NC}  已正常: ${GREEN}$count_ok${NC}  跳过: ${YELLOW}$count_skip${NC}  将迁移: ${YELLOW}$count_migrated${NC}"
else
  echo -e " 重建: ${GREEN}$count_relinked${NC}  已正常: ${GREEN}$count_ok${NC}  跳过: ${YELLOW}$count_skip${NC}  异常: ${RED}$count_broken${NC}  迁移: ${GREEN}$count_migrated${NC}"
fi
echo -e "${BLUE}=====================================${NC}"

# ---------- 全局 gitignore 检查提示 ----------
echo ""
echo -e "${CYAN}💡 提示: 请确保全局 gitignore 已配置 local 化规则${NC}"
echo -e "   检查: ${DIM}git config --global core.excludesFile${NC}"
echo -e "   规则: ${DIM}ai-task.local${NC} + ${DIM}*.local.md${NC}"
echo -e "   配置: ${DIM}参见 AI-TASK/setup.sh 或手动编辑 ~/.gitignore_global${NC}"
