#!/bin/bash
# =====================================================
# AI-TASK 软链接重建脚本 v1.0
# =====================================================
# 用法:
#   ./relink.sh            # 重建所有软链接
#   ./relink.sh --dry-run  # 预览，不实际操作
#   ./relink.sh --check    # 只检查当前软链接状态
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

# ---------- 参数解析 ----------
DRY_RUN=false
CHECK_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --check)   CHECK_ONLY=true ;;
  esac
done

# ---------- 软链接映射表 ----------
# 格式: "项目代号|代码仓库绝对路径"
# 维护说明：新增项目时在此表追加一行即可
declare -a LINK_MAP=(
  "TVKMM|$HOME/Desktop/Work/Project/TencentVideoKMM"
  "TVKMM|$HOME/Desktop/Work/Project/TencetVideoKMM_old"
  "L2D|$HOME/Desktop/Work/Project/live2d_demo"
  "DIAG-BUDDY|$HOME/Desktop/Work/Project/DiagnosisBuddy"
  "AGENT-TEAMS-DASHBOARD|$HOME/Desktop/Geek/AI/Agent/agent-teams-dashboard"
  "CHROME-BOOKMARK|$HOME/Desktop/Geek/AI/Agent/EntropyZero"
  "INFINITE-ENGINE|$HOME/Desktop/Geek/AI/Agent/Infinite-Engine"
  "INFINITE-ENGINE|$HOME/Desktop/Geek/AI/Agent/Infinite-Engine_副本"
  "ChatVRM|$HOME/Desktop/Geek/AI/Animate/ChatVRM"
  "DemoGLTF|$HOME/Desktop/Geek/AI/Animate/DemoGLTF"
  "Textoon|$HOME/Desktop/Geek/AI/Animate/Textoon"
  "SIRI-NAV|$HOME/Desktop/Geek/truck/apple-siri-voice-navigation"
  "FrostAtlas|$HOME/Desktop/Geek/ArnoFrost"
  "COMFYUI-INDEX-TTS|$HOME/Documents/ComfyUI/custom_nodes/ComfyUI-Index-TTS"
  "L2D-GENSTUDIO|$HOME/Documents/ComfyUI/custom_nodes/ComfyUI-Live2dGenStudio"
)

# ---------- 统计 ----------
count_ok=0
count_skip=0
count_broken=0
count_relinked=0

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE} AI-TASK 软链接重建脚本${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "AI-TASK 根目录: ${CYAN}$AI_TASK_ROOT${NC}"
$DRY_RUN   && echo -e "${YELLOW}[DRY-RUN 模式] 不会实际修改任何文件${NC}"
$CHECK_ONLY && echo -e "${CYAN}[CHECK 模式] 只检查状态，不修改${NC}"
echo ""

# ---------- 检查/重建 ----------
for entry in "${LINK_MAP[@]}"; do
  PROJECT_CODE="${entry%%|*}"
  REPO_PATH="${entry##*|}"
  LINK_PATH="$REPO_PATH/ai-task"
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

  # 软链接已存在且指向正确 → 无需操作
  if [ -L "$LINK_PATH" ] && [ "$(readlink "$LINK_PATH")" = "$TARGET" ]; then
    echo -e "  ${GREEN}OK${NC}    $PROJECT_CODE  →  $LINK_PATH"
    ((count_ok++)) || true
    continue
  fi

  # CHECK 模式：只报告，不修改
  if $CHECK_ONLY; then
    if [ -L "$LINK_PATH" ]; then
      OLD_TARGET="$(readlink "$LINK_PATH")"
      echo -e "  ${RED}STALE${NC} $PROJECT_CODE  →  $LINK_PATH"
      echo -e "         当前指向: $OLD_TARGET"
      echo -e "         应指向:   $TARGET"
    else
      echo -e "  ${RED}MISS${NC}  $PROJECT_CODE  →  $LINK_PATH  (软链接缺失)"
    fi
    ((count_broken++)) || true
    continue
  fi

  # DRY-RUN 模式：打印将要执行的命令
  if $DRY_RUN; then
    if [ -L "$LINK_PATH" ]; then
      echo -e "  ${YELLOW}WOULD${NC} rm \"$LINK_PATH\""
    fi
    echo -e "  ${YELLOW}WOULD${NC} ln -s \"$TARGET\" \"$LINK_PATH\""
    ((count_relinked++)) || true
    continue
  fi

  # 实际重建
  [ -L "$LINK_PATH" ] && rm "$LINK_PATH"
  ln -s "$TARGET" "$LINK_PATH"
  echo -e "  ${GREEN}RELINK${NC} $PROJECT_CODE  →  $LINK_PATH"
  ((count_relinked++)) || true
done

# ---------- 汇总 ----------
echo ""
echo -e "${BLUE}=====================================${NC}"
if $CHECK_ONLY; then
  echo -e " 正常: ${GREEN}$count_ok${NC}  异常: ${RED}$count_broken${NC}  跳过: ${YELLOW}$count_skip${NC}"
elif $DRY_RUN; then
  echo -e " 将重建: ${YELLOW}$count_relinked${NC}  已正常: ${GREEN}$count_ok${NC}  跳过: ${YELLOW}$count_skip${NC}"
else
  echo -e " 重建: ${GREEN}$count_relinked${NC}  已正常: ${GREEN}$count_ok${NC}  跳过: ${YELLOW}$count_skip${NC}  异常: ${RED}$count_broken${NC}"
fi
echo -e "${BLUE}=====================================${NC}"
