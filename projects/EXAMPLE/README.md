# 示例项目 — 协作规范

> 本文档定义 EXAMPLE 项目的 AI 协作约定，AI 引入 `index.md` 后自动遵循。

## 命名规范

- **任务格式**：`{YYYYMMDD}-{NNN}_[标签]任务名称.md`（full 模式）
- **编号规则**：全局递增，跨日期连续编号
- **标签**：使用 [SPEC.md 核心标签](../../SPEC.md#标签类型)，每个任务必须且只能使用 1 个

## 目录结构

```text
EXAMPLE/
├── project.yaml          # 项目元数据
├── index.md              # 项目入口（任务列表）
├── README.md             # 本文件（协作规范）
├── tasks/                # 进行中的任务
├── docs/                 # 项目文档
└── archive/              # 已完成任务归档
    └── YYYY-MM/
```

## 工作流

1. 引入 `@projects/EXAMPLE/index.md`
2. 描述需求，AI 自动创建任务文档
3. AI 执行任务并更新 `index.md` 状态
4. 完成后归档到 `archive/YYYY-MM/`

## 归档规则

| 条件 | 动作 |
|------|------|
| 任务状态 = 已完成 | 可归档 |
| 任务创建超过 30 天 | 建议归档 |
| index.md 任务超过 20 条 | 触发归档提醒 |

## 参考

- [全局规范](../../SPEC.md)
- [项目元数据](./project.yaml)
- [任务模板](../../templates/task-template.md)
