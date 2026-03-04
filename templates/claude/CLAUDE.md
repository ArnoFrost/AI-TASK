# {PROJECT_NAME}

> AI 协作入口文档

## 📌 项目信息

详见 `ai-task/project.yaml`

## 🔧 快捷命令

| 命令 | 说明 |
|------|------|
| `/task create [标签] 名称` | 创建任务 |
| `/task list` | 列出任务 |
| `/task update 编号 说明` | 更新进度 |
| `/task done 编号` | 标记完成 |
| `/init_sub_project <path>` | 初始化子项目 |

## 📂 AI-TASK 结构

```
ai-task/                    # 软链接 → AI-TASK/projects/{CODE}
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
```

## 📋 任务标签

`[功能]` `[优化]` `[修复]` `[排查]` `[文档]` `[调研]` `[技术方案]` `[规范]` `[下线]` `[清理]` `[梳理]` `[测试]` `[评审]` `[架构]` `[集成]` `[同步]`

## 🔗 子项目初始化

```bash
# 将子目录接入 AI-TASK
/init_sub_project ./packages/core

# 指定项目代号和名称
/init_sub_project ./modules/auth --code AUTH --name "认证模块"
```
