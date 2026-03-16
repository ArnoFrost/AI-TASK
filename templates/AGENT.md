# {PROJECT_NAME}

> AI 协作入口 · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 `ai-task.local/project.yaml`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task.local/tasks/ |
| 查看任务 | 查看 ai-task.local/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

`[功能]` `[优化]` `[修复]` `[排查]` `[文档]` `[调研]` `[技术方案]` `[规范]` `[下线]` `[清理]` `[梳理]` `[测试]` `[评审]` `[架构]` `[集成]` `[同步]`

## 结构

```
ai-task.local/              # 软链接 → AI-TASK/projects/{CODE}（已加入全局 gitignore）
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
```

## 规范

详见 ai-task.local/ 下的 [SPEC.md](../../SPEC.md)

<!--
存储策略: 此文件存储在 AI-TASK vault 的 projects/{CODE}/ 下，
工作仓库根目录通过 ai-task.local 软链接引用（全局 gitignore 忽略）。
跨设备运行 relink.sh 可自动重建。
可在此处追加项目特定的 AI 协作说明（如编码约定、架构偏好等）。
-->
