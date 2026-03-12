#!/usr/bin/env python3
"""
validate_obsidian.py — Obsidian Markdown 格式校验工具
校验：Mermaid 语法规则 + Frontmatter 必填字段

用法：
  python3 validate_obsidian.py <file.md>        # 校验单文件
  python3 validate_obsidian.py <dir/>           # 校验目录下所有 .md
  python3 validate_obsidian.py --help

退出码：0 = 全部通过，1 = 存在错误
"""
import re
import sys
from pathlib import Path

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RESET = "\033[0m"


def main():
    if "--help" in sys.argv or len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    args = sys.argv[1:]
    paths = []
    for arg in args:
        p = Path(arg)
        if p.is_dir():
            paths.extend(sorted(p.rglob("*.md")))
        elif p.is_file():
            paths.append(p)
        else:
            print(f"{RED}[ERROR]{RESET} 路径不存在: {arg}")
            sys.exit(1)

    if not paths:
        print(f"{YELLOW}[WARN]{RESET} 未找到任何 .md 文件")
        sys.exit(0)

    total_fail = 0
    for path in paths:
        errors = validate_file(path)
        if errors:
            total_fail += 1
            print(f"{RED}[FAIL]{RESET} {path}")
            for e in errors:
                print(f"  {e}")
        else:
            print(f"{GREEN}[PASS]{RESET} {path}")

    print(f"\nSummary: {total_fail} failed, {len(paths) - total_fail} passed")
    sys.exit(1 if total_fail > 0 else 0)


def validate_file(path: Path) -> list[str]:
    """返回错误列表，空列表表示通过"""
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    errors = []
    errors.extend(check_frontmatter(lines))
    errors.extend(check_mermaid(lines))
    return errors


REQUIRED_FRONTMATTER_FIELDS = {"date", "status", "type", "tags"}


def check_frontmatter(lines: list[str]) -> list[str]:
    """校验 frontmatter：存在性 + 必填字段"""
    errors = []
    if not lines or lines[0].strip() != "---":
        errors.append("[frontmatter] 缺少 frontmatter（文件应以 --- 开头）")
        return errors

    end = None
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            end = i
            break

    if end is None:
        errors.append("[frontmatter] frontmatter 未闭合（缺少结束 ---）")
        return errors

    found_fields = set()
    for line in lines[1:end]:
        m = re.match(r"^(\w+)\s*:", line)
        if m:
            found_fields.add(m.group(1))

    missing = REQUIRED_FRONTMATTER_FIELDS - found_fields
    for field in sorted(missing):
        errors.append(f"[frontmatter] 缺少必填字段: {field}")

    return errors


def check_mermaid(lines: list[str]) -> list[str]:
    """提取所有 mermaid 块并逐条检查语法规则"""
    errors = []
    blocks = _extract_mermaid_blocks(lines)
    for start_line, block_lines in blocks:
        for i, line in enumerate(block_lines, start=start_line + 1):
            errors.extend(_check_mermaid_line(line, i))
    return errors


def _extract_mermaid_blocks(lines: list[str]) -> list[tuple[int, list[str]]]:
    """返回 [(起始行号, [块内各行]), ...]，行号从 1 开始"""
    blocks = []
    in_block = False
    start = 0
    current: list[str] = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped == "```mermaid":
            in_block = True
            start = i
            current = []
        elif stripped == "```" and in_block:
            in_block = False
            blocks.append((start, current))
        elif in_block:
            current.append(line)
    if in_block:
        # 未闭合块，插入标记行让下游报错
        current.append("__UNCLOSED_MERMAID_BLOCK__")
        blocks.append((start, current))
    return blocks


def _check_mermaid_line(line: str, lineno: int) -> list[str]:
    """对单行执行所有 mermaid 规则，返回错误列表"""
    errors = []
    stripped = line.strip()
    if stripped == "__UNCLOSED_MERMAID_BLOCK__":
        return [f"[mermaid:L{lineno}] mermaid 块未闭合（缺少结束 ```）"]
    MERMAID_KEYWORDS = ("graph ", "flowchart ", "sequenceDiagram", "classDiagram", "subgraph ", "%%", "direction ")
    if not stripped or stripped == "end" or any(stripped.startswith(kw) for kw in MERMAID_KEYWORDS):
        return errors

    # 规则 1：节点 ID 不含中文
    id_match = re.match(r'^([^\s\[{(>"\-|]+)', stripped)
    if id_match:
        node_id = id_match.group(1)
        if re.search(r'[\u4e00-\u9fff]', node_id):
            errors.append(f"[mermaid:L{lineno}] 节点 ID 含中文: '{node_id}'（改用英文）")

    # 规则 2：菱形节点 {} 内含 & 或 <br/> 且未加引号
    diamond_match = re.search(r'\{([^}]+)\}', stripped)
    if diamond_match:
        content = diamond_match.group(1)
        inner = content.strip()
        if not (inner.startswith('"') and inner.endswith('"')):
            if '&' in inner:
                errors.append(f"[mermaid:L{lineno}] 菱形节点含 '&' 未加引号: '{stripped}'")
            if '<br' in inner:
                errors.append(f"[mermaid:L{lineno}] 菱形节点含 '<br/>' 应用引号包裹: '{stripped}'")

    # 规则 3：边标签前有多余空格（--> |label| 或 -- |label|）
    if re.search(r'--+>\s+\|', stripped) or re.search(r'--\s+\|', stripped):
        errors.append(f"[mermaid:L{lineno}] 边标签前有空格（应紧贴箭头，如 -->|label|）: '{stripped}'")

    # 规则 4：中文/多词边标签未加引号（-- 文字 --> 形式）
    # 匹配 -- 非引号内容包含中文 --> 的模式
    cn_label = re.search(r'--\s+([\u4e00-\u9fff\w\s]+?)\s*-->', stripped)
    if cn_label:
        label_text = cn_label.group(1).strip()
        if re.search(r'[\u4e00-\u9fff]', label_text):
            # 检查该匹配段内是否有引号包裹
            match_slice = stripped[cn_label.start():cn_label.end()]
            if '"' not in match_slice:
                errors.append(
                    f"[mermaid:L{lineno}] 中文边标签未加引号: '-- {label_text} -->'（改为 -- \"标签\" -->）"
                )

    # 规则 5：含括号的节点标签文本未加引号
    paren_in_label = re.search(r'\[([^\]"]*\([^\]"]*\)[^\]"]*)\]', stripped)
    if paren_in_label:
        errors.append(
            f"[mermaid:L{lineno}] 节点文本含括号未加引号: '{paren_in_label.group(0)}'（改为 [\"...\"]）"
        )

    return errors


if __name__ == "__main__":
    main()
