# 模板库

> AI-TASK 核心模板文件

## 模板列表

| 模板文件 | 用途 | 使用场景 |
|----------|------|----------|
| `project.yaml` | 项目元数据（完整版） | 需要高级配置时使用 |
| `project-minimal.yaml` | 项目元数据（精简版） | 快速开始推荐 |
| `project-index.md` | 项目入口文档 | 项目 `index.md` 模板 |
| `task-template.md` | 任务文档 | 创建新任务时使用 |
| `review-actions.yaml` | 评审行动项索引 | 评审产出的行动项 schema |
| `project-rules.md` | 规则模板 | 项目规则定义 |
| `AGENT.md` | 通用 AI 协作入口 | IDE 无关的 AI 入口模板 |

## 使用方式

### 初始化新项目

```bash
# 使用脚本自动初始化（推荐）
./init-project.sh

# 或手动复制模板
cp templates/project.yaml projects/{PROJECT}/
cp templates/project-index.md projects/{PROJECT}/index.md
```

### 创建任务

```bash
# 手动复制模板（NNN 为全局递增，取 tasks/ 目录最大 NNN + 1）
cp templates/task-template.md projects/{PROJECT}/tasks/YYYYMMDD-NNN_[标签]名称.md
```

## 相关链接

- [全局规范](../SPEC.md)
- [技能库](../skills/README.md)
- [示例项目](../projects/EXAMPLE/)
