在 AI-TASK 大仓中创建新的子项目。

## 用户输入

$ARGUMENTS

## 参数解析

```
/init_sub_project <CODE> [--name NAME] [--tech TECH] [--path PATH]
```

| 参数 | 必需 | 说明 |
|------|------|------|
| `CODE` | ✅ | 项目代号（大写，如 MYAPP） |
| `--name` | ⚪ | 项目名称，默认同代号 |
| `--tech` | ⚪ | 技术栈，逗号分隔 |
| `--path` | ⚪ | 关联的外部项目路径（可选） |
| `--help` | ⚪ | 显示帮助 |

## 执行流程

### 1. 前置校验

```yaml
checks:
  - name: 在 AI-TASK 大仓内
    action: 检查当前目录是否为 AI-TASK 仓库（存在 projects/ 和 SPEC.md）
    on_fail: "错误: 请在 AI-TASK 仓库根目录执行此命令"
    
  - name: CODE 冲突检测
    action: 检查 projects/{CODE} 是否已存在
    on_fail: "错误: 项目 '{CODE}' 已存在"
```

### 2. 创建项目结构

在 `projects/` 目录下创建：

```
projects/{CODE}/
├── project.yaml          # 项目元数据
├── index.md              # 项目入口
├── tasks/                # 任务目录
│   └── .gitkeep
└── docs/                 # 文档目录
    └── .gitkeep
```

### 3. 生成 project.yaml

```yaml
code: {CODE}
name: {NAME}

paths:
  - {PATH}  # 如果提供了 --path

tech_stack:
  - {TECH_1}
  - {TECH_2}

created: {TODAY}
status: active

tags: []
```

### 4. 生成 index.md

```markdown
# {NAME}

> {CODE} 项目

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | {TECH_STACK} |
| **创建时间** | {TODAY} |

---

## 📋 任务列表

### 进行中 🔄

_暂无进行中任务_

### 已完成 ✅

_暂无已完成任务_

---

## 🔗 快捷链接

- [任务目录](./tasks/)
- [文档目录](./docs/)
- [全局规范](../../SPEC.md)
```

### 5. 初始化子项目 Git（可选）

如果 tasks/ 或 docs/ 目录需要独立 Git 管理：

```bash
cd projects/{CODE}/tasks && git init && git add . && git commit -m "init: {CODE} tasks"
cd projects/{CODE}/docs && git init && git add . && git commit -m "init: {CODE} docs"
```

### 6. 输出结果

```
✅ 项目 {CODE} 创建完成!

创建的文件:
  - projects/{CODE}/project.yaml
  - projects/{CODE}/index.md
  - projects/{CODE}/tasks/.gitkeep
  - projects/{CODE}/docs/.gitkeep

下一步:
  1. 编辑 projects/{CODE}/project.yaml 补充项目信息
  2. 使用 /task create 创建任务（需先 cd 到项目目录）
  3. 如需关联外部项目，运行 init-project.sh
```

## 帮助信息

```
/init_sub_project 命令用法:

  /init_sub_project <CODE>                    创建新项目
  /init_sub_project <CODE> --name NAME        指定项目名称
  /init_sub_project <CODE> --tech "A, B"      指定技术栈
  /init_sub_project <CODE> --path /path/to    关联外部路径

示例:
  /init_sub_project MYAPP
  /init_sub_project MYAPP --name "我的应用" --tech "React, TypeScript"
  /init_sub_project DEMO --path ~/Projects/demo
```

## 与其他命令的关系

| 场景 | 推荐命令 |
|------|----------|
| 在 AI-TASK 大仓内创建新项目 | `/init_sub_project CODE` |
| 将外部项目接入 AI-TASK | `./init-project.sh` (Shell) |
| 在已接入项目的子目录创建子项目 | 在外部项目内执行 `/init_sub_project` |
