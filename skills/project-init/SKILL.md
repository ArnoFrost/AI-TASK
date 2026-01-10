---
name: project-init
description: |
  初始化新项目的 AI 协作配置。创建项目目录结构、生成 project.yaml 和 index.md、配置软链接。
  Use when: 新建项目、初始化项目、配置项目、project init
---

# 项目初始化技能

## 🎯 能力范围

- 创建项目目录结构
- 生成项目配置文件
- 配置软链接
- 初始化项目索引

## 📐 项目结构

```
AI-TASK/projects/{PROJECT_CODE}/
├── index.md          # 项目入口
├── README.md         # 快捷说明
├── tasks/            # 任务目录
├── docs/             # 项目文档
└── rules/            # 项目级规则（可选）
```

## 🔧 初始化步骤

### 输入信息

```yaml
project_code: XXX           # 项目代号（大写字母）
project_name: xxx           # 项目名称
local_path: /path/to/project  # 本地项目路径
tech_stack: Kotlin, ...     # 技术栈
description: 项目描述        # 简要描述
```

### 执行步骤

1. **创建目录结构**
   ```bash
   mkdir -p projects/{CODE}/tasks
   mkdir -p projects/{CODE}/docs
   ```

2. **生成 index.md**
   - 使用项目模板
   - 填充项目信息

3. **生成 README.md**
   - 快捷入口说明

4. **配置软链接**
   ```bash
   ln -s "AI-TASK/projects/{CODE}" "{LOCAL_PATH}/ai-task"
   ```

5. **更新全局 README.md**
   - 添加到项目索引表

## 📋 项目模板

```markdown
# {PROJECT_NAME}

> {DESCRIPTION}

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **本地路径** | `{LOCAL_PATH}` |
| **主要技术栈** | {TECH_STACK} |
| **创建时间** | {DATE} |

---

## 📋 任务列表

### 进行中 🔄
- 无

### 已完成 ✅
- 无

---

## 🔗 快捷链接

- [任务目录](./tasks/)
- [文档目录](./docs/)
- [全局规范](../../README.md)
```
