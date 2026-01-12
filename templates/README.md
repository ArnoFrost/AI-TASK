# 模板库

> AI-TASK 项目模板文件说明

## 📂 模板列表

| 模板文件 | 用途 | 使用场景 |
|----------|------|----------|
| `project.yaml` | 项目元数据（完整版） | 需要高级配置时使用 |
| `project-minimal.yaml` | 项目元数据（精简版） | ⭐ 快速开始推荐 |
| `project-index.md` | 项目入口文档 | 项目 `index.md` 模板 |
| `task-template.md` | 任务文档 | 创建新任务时使用 |
| `daily-summary.md` | 日报模板 | 生成每日工作总结 |
| `project-config.md` | 配置说明 | 项目配置参考 |
| `project-rules.md` | 规则模板 | 项目规则定义 |
| `ai-prompt-guide.md` | AI 提示词指南 | AI 协作提示词参考 |

## 📁 IDE 配置模板

| 目录 | 用途 |
|------|------|
| `claude/` | Claude Code 配置模板 |
| `codebuddy/` | CodeBuddy 配置模板 |

## 🚀 使用方式

### 初始化新项目

```bash
# 使用脚本自动初始化
./init-project.sh <PROJECT_CODE> "<PROJECT_NAME>" "<PROJECT_PATH>"

# 或手动复制模板
cp templates/project.yaml projects/{PROJECT}/
cp templates/project-index.md projects/{PROJECT}/index.md
```

### 创建任务

```bash
# 使用斜杠命令
/task create [功能] 用户登录模块

# 或手动复制模板
cp templates/task-template.md projects/{PROJECT}/tasks/YYYYMMDD-NNN_[标签]名称.md
```

## 🔗 相关链接

- [全局规范](../SPEC.md)
- [示例项目](../projects/EXAMPLE/)
