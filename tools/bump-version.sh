#!/bin/bash
# =====================================================
# AI-TASK 版本号批量演进工具
# =====================================================
# 自动扫描并更新仓库中所有硬编码版本号的位置，
# 确保发版时不会遗漏任何文件。
#
# 用法:
#   ./tools/bump-version.sh <new_version>
#   ./tools/bump-version.sh 2.3.0
#   ./tools/bump-version.sh 2.3.0 --dry-run    # 仅预览，不修改
#   ./tools/bump-version.sh --check             # 检查一致性
#
# 维护的版本号位置 (VERSION_FILES):
#   1. README.md          — shields.io 版本徽章
#   2. README_EN.md       — shields.io 版本徽章
#   3. CODEBUDDY.md       — 标题行 "· vX.Y.Z"
#   4. setup.sh           — 注释头 "v X.Y.Z"
#   5. CHANGELOG.md       — 需手动编写条目，脚本仅验证
# =====================================================

set -euo pipefail

# ======================== 配置 ========================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ANSI 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 版本号正则 (X.Y.Z)
VERSION_REGEX='[0-9]+\.[0-9]+\.[0-9]+'

# ======================== 工具函数 ========================

usage() {
    cat <<EOF
${BOLD}AI-TASK 版本号批量演进工具${NC}

${CYAN}用法:${NC}
  $0 <new_version>             更新所有文件中的版本号
  $0 <new_version> --dry-run   预览变更，不实际修改
  $0 --check                   检查当前版本号一致性

${CYAN}示例:${NC}
  $0 2.3.0
  $0 2.3.0 --dry-run
  $0 --check

${CYAN}维护的文件:${NC}
  README.md        版本徽章 (shields.io badge)
  README_EN.md     版本徽章 (shields.io badge)
  CODEBUDDY.md     标题行版本 "· vX.Y.Z"
  setup.sh         注释头版本号
  CHANGELOG.md     版本记录 (仅验证，需手动编写)
EOF
}

die() {
    echo -e "${RED}✗ $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

ok() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 验证版本号格式
validate_version() {
    local ver="$1"
    if [[ ! "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        die "无效的版本号格式: '$ver' (期望 X.Y.Z，如 2.3.0)"
    fi
}

# 从文件中提取当前版本号
extract_version() {
    local file="$1"
    local pattern="$2"
    grep -oE "$pattern" "$file" 2>/dev/null | grep -oE "$VERSION_REGEX" | head -1
}

# ======================== 版本号位置定义 ========================
#
# 每个条目定义: 文件路径、搜索模式、替换逻辑
# 新增版本号位置时只需在此处追加

declare -a VERSION_FILES=(
    "README.md"
    "README_EN.md"
    "CODEBUDDY.md"
    "setup.sh"
)

# 提取各文件的当前版本号
get_file_version() {
    local file="$1"
    local filepath="$REPO_ROOT/$file"

    case "$file" in
        README.md|README_EN.md)
            extract_version "$filepath" "version-${VERSION_REGEX}-green"
            ;;
        CODEBUDDY.md)
            extract_version "$filepath" "v${VERSION_REGEX}"
            ;;
        setup.sh)
            extract_version "$filepath" "v${VERSION_REGEX}"
            ;;
    esac
}

# 更新单个文件的版本号
update_file_version() {
    local file="$1"
    local old_ver="$2"
    local new_ver="$3"
    local filepath="$REPO_ROOT/$file"

    case "$file" in
        README.md|README_EN.md)
            # shields.io badge: version-X.Y.Z-green
            sed -i '' "s/version-${old_ver}-green/version-${new_ver}-green/g" "$filepath"
            ;;
        CODEBUDDY.md)
            # 标题行: · vX.Y.Z
            sed -i '' "s/v${old_ver}/v${new_ver}/g" "$filepath"
            ;;
        setup.sh)
            # 注释头: 脚本 vX.Y.Z
            sed -i '' "s/v${old_ver}/v${new_ver}/g" "$filepath"
            ;;
    esac
}

# ======================== 子命令：检查一致性 ========================

cmd_check() {
    echo -e "${BOLD}🔍 版本号一致性检查${NC}"
    echo ""

    local versions=()
    local all_same=true
    local first_ver=""

    for file in "${VERSION_FILES[@]}"; do
        local filepath="$REPO_ROOT/$file"
        if [[ ! -f "$filepath" ]]; then
            warn "$file — 文件不存在"
            continue
        fi

        local ver
        ver="$(get_file_version "$file")"

        if [[ -z "$ver" ]]; then
            warn "$file — ${DIM}未找到版本号${NC}"
            all_same=false
            continue
        fi

        if [[ -z "$first_ver" ]]; then
            first_ver="$ver"
        elif [[ "$ver" != "$first_ver" ]]; then
            all_same=false
        fi

        versions+=("$ver")
        echo -e "  ${CYAN}$file${NC} → ${BOLD}$ver${NC}"
    done

    # 检查 CHANGELOG
    local changelog_ver
    changelog_ver="$(grep -oE '## \['"$VERSION_REGEX"'\]' "$REPO_ROOT/CHANGELOG.md" | head -1 | grep -oE "$VERSION_REGEX")"
    echo -e "  ${CYAN}CHANGELOG.md${NC} → ${BOLD}${changelog_ver:-未找到}${NC} (最新条目)"

    # 检查 git tag
    local latest_tag
    latest_tag="$(cd "$REPO_ROOT" && git tag --sort=-v:refname | head -1 2>/dev/null)"
    local tag_ver="${latest_tag#v}"
    echo -e "  ${CYAN}git tag${NC} → ${BOLD}${latest_tag:-无}${NC} (最新标签)"

    echo ""

    if $all_same && [[ "$first_ver" == "$changelog_ver" ]] && [[ "$first_ver" == "$tag_ver" ]]; then
        ok "所有版本号一致: ${BOLD}$first_ver${NC} ✅"
        return 0
    else
        warn "版本号不一致，需要修正:"
        [[ "$first_ver" != "$changelog_ver" ]] && echo -e "  ${DIM}- 文件版本 ($first_ver) ≠ CHANGELOG ($changelog_ver)${NC}"
        [[ "$first_ver" != "$tag_ver" ]] && echo -e "  ${DIM}- 文件版本 ($first_ver) ≠ git tag ($tag_ver)${NC}"
        if ! $all_same; then
            echo -e "  ${DIM}- 文件之间版本号不一致${NC}"
        fi
        echo ""
        echo -e "  运行 ${CYAN}$0 <version>${NC} 来统一版本号"
        return 1
    fi
}

# ======================== 子命令：更新版本号 ========================

cmd_bump() {
    local new_ver="$1"
    local dry_run="${2:-false}"

    validate_version "$new_ver"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "${BOLD}🔍 版本号更新预览 (dry-run)${NC}"
    else
        echo -e "${BOLD}🚀 版本号批量更新 → ${GREEN}$new_ver${NC}"
    fi
    echo ""

    local updated=0
    local skipped=0
    local unchanged=0

    for file in "${VERSION_FILES[@]}"; do
        local filepath="$REPO_ROOT/$file"
        if [[ ! -f "$filepath" ]]; then
            warn "$file — 文件不存在，跳过"
            skipped=$((skipped + 1))
            continue
        fi

        local old_ver
        old_ver="$(get_file_version "$file")"

        if [[ -z "$old_ver" ]]; then
            warn "$file — 未找到版本号，跳过"
            skipped=$((skipped + 1))
            continue
        fi

        if [[ "$old_ver" == "$new_ver" ]]; then
            echo -e "  ${DIM}$file — 已经是 ${new_ver}，跳过${NC}"
            unchanged=$((unchanged + 1))
            continue
        fi

        if [[ "$dry_run" == "true" ]]; then
            echo -e "  ${CYAN}$file${NC}: $old_ver → ${GREEN}$new_ver${NC}"
        else
            update_file_version "$file" "$old_ver" "$new_ver"
            echo -e "  ${GREEN}✓${NC} ${CYAN}$file${NC}: $old_ver → ${GREEN}$new_ver${NC}"
        fi
        updated=$((updated + 1))
    done

    echo ""

    # CHANGELOG 检查
    local changelog_has_version
    if grep -qE "## \\[$new_ver\\]" "$REPO_ROOT/CHANGELOG.md" 2>/dev/null; then
        ok "CHANGELOG.md 已包含 [$new_ver] 条目"
    else
        warn "CHANGELOG.md 缺少 [$new_ver] 条目 — 请手动添加发版记录"
    fi

    # git tag 提示
    local existing_tag
    existing_tag="$(cd "$REPO_ROOT" && git tag -l "v$new_ver" 2>/dev/null)"
    if [[ -n "$existing_tag" ]]; then
        info "git tag v$new_ver 已存在"
    else
        echo -e "  ${DIM}发版时记得: git tag -a v$new_ver -m \"v$new_ver — ...\"${NC}"
    fi

    echo ""

    if [[ "$dry_run" == "true" ]]; then
        info "Dry-run 完成，实际运行请去掉 --dry-run"
        echo -e "  ${CYAN}$0 $new_ver${NC}"
    else
        if [[ $updated -gt 0 ]]; then
            ok "已更新 $updated 个文件"
            if [[ $skipped -gt 0 ]]; then
                warn "跳过 $skipped 个文件"
            fi
            echo ""
            echo -e "${BOLD}下一步:${NC}"
            echo -e "  1. ${DIM}编写 CHANGELOG.md 发版记录（如果尚未编写）${NC}"
            echo -e "  2. ${CYAN}git add -A && git commit -m \"发版: v$new_ver — ...\"${NC}"
            echo -e "  3. ${CYAN}git tag -a v$new_ver -m \"v$new_ver — ...\"${NC}"
            echo -e "  4. ${CYAN}git push origin <branch> --tags${NC}"
        else
            info "所有文件已是最新版本，无需更新"
        fi
    fi
}

# ======================== 主入口 ========================

main() {
    cd "$REPO_ROOT"

    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi

    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --check)
            cmd_check
            ;;
        *)
            local new_ver="$1"
            local dry_run="false"
            if [[ "${2:-}" == "--dry-run" ]]; then
                dry_run="true"
            fi
            cmd_bump "$new_ver" "$dry_run"
            ;;
    esac
}

main "$@"
