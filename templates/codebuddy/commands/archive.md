归档已完成的任务到 archive 目录。

## 用户输入

$ARGUMENTS

## 参数解析

```
/archive [任务编号] [--all] [--month YYYY-MM]
```

| 参数 | 必需 | 说明 |
|------|------|------|
| `任务编号` | ⚪ | 指定归档的任务编号 |
| `--all` | ⚪ | 归档所有已完成任务 |
| `--month` | ⚪ | 指定归档月份，默认按任务创建月份 |
| `--help` | ⚪ | 显示帮助 |

## 执行流程

### 1. 前置校验

```yaml
checks:
  - name: AI-TASK 可达性
    action: 检查当前项目是否已接入 AI-TASK
    on_fail: "错误: 当前项目未接入 AI-TASK"
    
  - name: 任务存在性
    action: 检查指定任务是否存在
    on_fail: "错误: 任务 '{编号}' 不存在"
    
  - name: 任务状态
    action: 检查任务是否已完成
    on_fail: "警告: 任务 '{编号}' 尚未完成，是否强制归档? (y/N)"
```

### 2. 归档操作

```yaml
archive:
  source: ai-task/tasks/{任务文件}
  target: ai-task/archive/{YYYY-MM}/{任务文件}
  
  steps:
    - 创建目标月份目录 (如不存在)
    - 移动任务文件
    - 更新 ai-task/index.md 任务列表
```

### 3. 目录结构

```
ai-task/
├── tasks/                    # 活跃任务
│   └── 20260110-001_xxx.md
└── archive/                  # 归档任务
    ├── 2025-12/
    │   ├── 20251211-001_xxx.md
    │   └── 20251215-002_xxx.md
    └── 2026-01/
        └── 20260105-001_xxx.md
```

### 4. 输出结果

```
✅ 任务归档完成!

归档详情:
  - 20260108-001_xxx.md → archive/2026-01/
  
当前状态:
  - 活跃任务: 3 个
  - 归档任务: 15 个
```

## 帮助信息

```
/archive 命令用法:

  /archive 001                    归档指定任务
  /archive --all                  归档所有已完成任务
  /archive --month 2025-12        归档到指定月份目录

示例:
  /archive 001
  /archive 20260108-001
  /archive --all
```
