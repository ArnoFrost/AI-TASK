#!/bin/bash
# ============================================================================
# AI-TASK 模板同步脚本
# ============================================================================
# 用法:
#   ./sync-templates.sh                    # 同步所有项目
#   ./sync-templates.sh dotfiles TVKMM     # 只同步指定项目
#   ./sync-templates.sh --dry-run          # 预览变更，不实际修改
#   ./sync-templates.sh --dry-run dotfiles # 预览指定项目
#
# 同步规则:
#   - 读取 templates/project.yaml 作为基准模板
#   - 遍历 projects/*/project.yaml 进行增量合并
#   - 子仓可通过 sync.enabled: false 跳过同步
#   - 子仓可通过 sync.locked_fields 锁定特定字段
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本所在目录（AI-TASK 根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/templates/project.yaml"
PROJECTS_DIR="$SCRIPT_DIR/projects"

# 参数解析
DRY_RUN=false
SPECIFIED_PROJECTS=()

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "用法: $0 [--dry-run] [PROJECT_CODE...]"
            echo ""
            echo "选项:"
            echo "  --dry-run    预览变更，不实际修改文件"
            echo "  --help       显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                      # 同步所有项目"
            echo "  $0 dotfiles TVKMM       # 只同步指定项目"
            echo "  $0 --dry-run            # 预览所有变更"
            exit 0
            ;;
        *)
            SPECIFIED_PROJECTS+=("$arg")
            ;;
    esac
done

# 检查模板文件
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo -e "${RED}错误: 模板文件不存在: $TEMPLATE_FILE${NC}"
    exit 1
fi

# 检查 yq 是否安装（用于 YAML 处理）
if ! command -v yq &> /dev/null; then
    echo -e "${YELLOW}警告: yq 未安装，将使用简化的文本处理方式${NC}"
    echo -e "${YELLOW}建议安装 yq 以获得更好的 YAML 处理能力: brew install yq${NC}"
    USE_YQ=false
else
    USE_YQ=true
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}AI-TASK 模板同步${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}[预览模式] 不会实际修改文件${NC}"
    echo ""
fi

# 统计
TOTAL=0
SYNCED=0
SKIPPED=0
FAILED=0

# 获取模板中的 task_naming 配置
get_template_task_naming() {
    if [[ "$USE_YQ" == true ]]; then
        yq -r '.task_naming // empty' "$TEMPLATE_FILE" 2>/dev/null || echo ""
    else
        # 简化处理：检查模板是否有 task_naming
        grep -q "^task_naming:" "$TEMPLATE_FILE" && echo "exists" || echo ""
    fi
}

# 检查项目是否有 task_naming 配置
has_task_naming() {
    local project_yaml="$1"
    grep -q "^task_naming:" "$project_yaml" 2>/dev/null
}

# 检查 sync.enabled
is_sync_enabled() {
    local project_yaml="$1"
    if [[ "$USE_YQ" == true ]]; then
        local enabled=$(yq -r '.sync.enabled // true' "$project_yaml" 2>/dev/null)
        [[ "$enabled" != "false" ]]
    else
        # 简化处理：检查是否有 sync.enabled: false
        ! grep -q "enabled: false" "$project_yaml" 2>/dev/null
    fi
}

# 检查字段是否被锁定
is_field_locked() {
    local project_yaml="$1"
    local field="$2"
    if [[ "$USE_YQ" == true ]]; then
        yq -r ".sync.locked_fields // [] | .[]" "$project_yaml" 2>/dev/null | grep -q "^${field}$"
    else
        # 简化处理：检查 locked_fields 中是否包含该字段
        # 使用 -- 告诉 grep 后面没有选项了
        grep -A 10 "locked_fields:" "$project_yaml" 2>/dev/null | grep -q -- "- ${field}"
    fi
}

# 添加 task_naming 配置到项目
add_task_naming() {
    local project_yaml="$1"
    local project_code="$2"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${GREEN}+ 将添加 task_naming 配置${NC}"
        return 0
    fi

    # 创建临时文件
    local tmp_file=$(mktemp)
    
    # task_naming 配置块
    local task_naming_block='# 任务命名配置
task_naming:
  # 格式选项: full | date | simple | custom
  format: "full"
  # 自定义格式 (仅 format: "custom" 时生效)
  # pattern: "{DATE}-{NNN}_{TAG}{NAME}.md"
  # 序号位数 (默认 3)
  # seq_digits: 3

'

    # 在 tech_stack 之前插入（如果存在），否则在文件末尾添加
    if grep -q "^tech_stack:" "$project_yaml"; then
        # 逐行处理，在 tech_stack 之前插入
        local inserted=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^tech_stack: ]] && [[ "$inserted" == false ]]; then
                echo "$task_naming_block" >> "$tmp_file"
                inserted=true
            fi
            echo "$line" >> "$tmp_file"
        done < "$project_yaml"
        mv "$tmp_file" "$project_yaml"
    else
        # 追加到文件末尾
        echo "" >> "$project_yaml"
        echo "$task_naming_block" >> "$project_yaml"
    fi
    
    echo -e "  ${GREEN}✓ 已添加 task_naming 配置${NC}"
}

# 添加 sync 配置到项目
add_sync_config() {
    local project_yaml="$1"
    
    local sync_block='
# 模板同步配置
sync:
  enabled: true           # false = 跳过此项目的模板同步
  strategy: "merge"       # merge | skip | force
  locked_fields: []       # 不被同步覆盖的字段，如: [task_naming, tech_stack]
'

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${GREEN}+ 将添加 sync 配置${NC}"
        return 0
    fi

    # 追加到文件末尾
    echo "$sync_block" >> "$project_yaml"
    echo -e "  ${GREEN}✓ 已添加 sync 配置${NC}"
}

# 检查项目是否有 sync 配置
has_sync_config() {
    local project_yaml="$1"
    grep -q "^sync:" "$project_yaml" 2>/dev/null
}

# 同步单个项目
sync_project() {
    local project_dir="$1"
    local project_code=$(basename "$project_dir")
    local project_yaml="$project_dir/project.yaml"
    
    ((TOTAL++))
    
    echo -e "${BLUE}[$project_code]${NC}"
    
    # 检查 project.yaml 是否存在
    if [[ ! -f "$project_yaml" ]]; then
        echo -e "  ${YELLOW}⚠ project.yaml 不存在，跳过${NC}"
        ((SKIPPED++))
        return
    fi
    
    # 检查是否启用同步
    if ! is_sync_enabled "$project_yaml"; then
        echo -e "  ${YELLOW}⚠ sync.enabled: false，跳过${NC}"
        ((SKIPPED++))
        return
    fi
    
    local changes_made=false
    
    # 检查并添加 task_naming
    if ! has_task_naming "$project_yaml"; then
        if is_field_locked "$project_yaml" "task_naming"; then
            echo -e "  ${YELLOW}⚠ task_naming 被锁定，跳过${NC}"
        else
            add_task_naming "$project_yaml" "$project_code"
            changes_made=true
        fi
    else
        echo -e "  ${GREEN}✓ task_naming 已存在${NC}"
    fi
    
    # 检查并添加 sync 配置
    if ! has_sync_config "$project_yaml"; then
        add_sync_config "$project_yaml"
        changes_made=true
    else
        echo -e "  ${GREEN}✓ sync 配置已存在${NC}"
    fi
    
    if [[ "$changes_made" == true ]]; then
        ((SYNCED++))
    else
        echo -e "  ${GREEN}✓ 无需更新${NC}"
    fi
    
    echo ""
}

# 主逻辑
echo -e "模板文件: ${TEMPLATE_FILE}"
echo -e "项目目录: ${PROJECTS_DIR}"
echo ""

# 遍历项目
if [[ ${#SPECIFIED_PROJECTS[@]} -gt 0 ]]; then
    # 只同步指定项目
    for project_code in "${SPECIFIED_PROJECTS[@]}"; do
        project_dir="$PROJECTS_DIR/$project_code"
        if [[ -d "$project_dir" ]]; then
            sync_project "$project_dir"
        else
            echo -e "${RED}错误: 项目不存在: $project_code${NC}"
            ((FAILED++))
        fi
    done
else
    # 同步所有项目
    for project_dir in "$PROJECTS_DIR"/*/; do
        if [[ -d "$project_dir" ]]; then
            sync_project "$project_dir"
        fi
    done
fi

# 输出统计
echo -e "${BLUE}============================================${NC}"
echo -e "统计: 总计 ${TOTAL} | 同步 ${GREEN}${SYNCED}${NC} | 跳过 ${YELLOW}${SKIPPED}${NC} | 失败 ${RED}${FAILED}${NC}"

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo -e "${YELLOW}[预览模式] 以上为预览结果，未实际修改文件${NC}"
    echo -e "${YELLOW}移除 --dry-run 参数以执行实际同步${NC}"
fi
