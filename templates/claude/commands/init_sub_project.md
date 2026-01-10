初始化子项目，将子目录接入 AI-TASK 协作体系。

## 用户输入

$ARGUMENTS

## 参数解析

```
/init_sub_project <path> [--code CODE] [--name NAME] [--tech TECH]
```

| 参数 | 必需 | 说明 |
|------|------|------|
| `path` | ✅ | 子项目路径（相对或绝对） |
| `--code` | ⚪ | 项目代号，默认从目录名推断（大写） |
| `--name` | ⚪ | 项目名称，默认同代号 |
| `--tech` | ⚪ | 技术栈，逗号分隔 |
| `--help` | ⚪ | 显示帮助 |

## 执行流程

### 1. 前置校验

```yaml
checks:
  - name: 路径存在性
    action: 检查 path 是否存在且为目录
    on_fail: "错误: 路径 '{path}' 不存在或不是目录"
    
  - name: AI-TASK 可达性
    action: 检查当前项目是否已接入 AI-TASK (存在 ai-task/ 软链接)
    on_fail: "错误: 当前项目未接入 AI-TASK，请先运行 init-project.sh"
    
  - name: 重复初始化检测
    action: 检查目标路径是否已有 ai-task/ 软链接
    on_fail: "警告: '{path}' 已初始化，是否覆盖? (y/N)"
    
  - name: CODE 冲突检测
    action: 检查 AI-TASK/projects/{CODE} 是否已存在
    on_fail: "警告: 项目代号 '{CODE}' 已存在，请指定 --code 参数"
```

### 2. 信息推断

```yaml
infer:
  code:
    - 优先使用 --code 参数
    - 否则从目录名推断，转大写，去除特殊字符
    - 示例: packages/core → CORE, my-module → MYMODULE
    
  name:
    - 优先使用 --name 参数
    - 否则尝试读取 package.json 的 name 字段
    - 否则尝试读取 build.gradle 的 rootProject.name
    - 否则使用目录名
    
  tech_stack:
    - 优先使用 --tech 参数
    - 否则自动检测:
      - package.json 存在 → Node.js/JavaScript
      - tsconfig.json 存在 → TypeScript
      - build.gradle.kts 存在 → Kotlin
      - build.gradle 存在 → Java/Gradle
      - Cargo.toml 存在 → Rust
      - go.mod 存在 → Go
      - requirements.txt/pyproject.toml 存在 → Python
```

### 3. 获取 AI-TASK 路径

```bash
# 通过软链接获取 AI-TASK 根目录
AI_TASK_ROOT=$(dirname $(dirname $(readlink ai-task)))
```

### 4. 创建项目结构

在 AI-TASK 中创建：

```
AI-TASK/projects/{CODE}/
├── project.yaml          # 项目元数据
├── index.md              # 项目入口
├── tasks/                # 任务目录
└── docs/                 # 文档目录
```

#### project.yaml 内容

```yaml
code: {CODE}
name: {NAME}

paths:
  - {ABSOLUTE_PATH}

tech_stack:
  - {TECH_1}
  - {TECH_2}

created: {TODAY}
status: active

tags: []

related:
  - {PARENT_CODE}  # 关联父项目

metadata:
  parent: {PARENT_CODE}
  description: {NAME} 子项目
```

#### index.md 内容

```markdown
# {NAME}

> {CODE} 子项目

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **父项目** | {PARENT_CODE} |
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
- [父项目](../{PARENT_CODE}/index.md)
- [全局规范](../../SPEC.md)
```

### 5. 创建软链接

```bash
ln -s "{AI_TASK_ROOT}/projects/{CODE}" "{SUB_PROJECT_PATH}/ai-task"
```

### 6. 生成 Claude Code 配置

在子项目目录创建：

```
{SUB_PROJECT_PATH}/
├── CLAUDE.md
└── .claude/
    └── commands/
        ├── task.md
        └── init_sub_project.md
```

### 7. 更新父项目关联

在父项目的 `project.yaml` 中添加 related:

```yaml
related:
  - {CODE}  # 新增子项目关联
```

### 8. 输出结果

```
✅ 子项目 {CODE} 初始化完成!

创建的文件:
  - AI-TASK/projects/{CODE}/project.yaml
  - AI-TASK/projects/{CODE}/index.md
  - AI-TASK/projects/{CODE}/tasks/
  - {SUB_PROJECT_PATH}/ai-task (软链接)
  - {SUB_PROJECT_PATH}/CLAUDE.md
  - {SUB_PROJECT_PATH}/.claude/commands/task.md

下一步:
  1. 编辑 ai-task/project.yaml 补充项目信息
  2. 使用 /task create 创建任务
```

## 错误处理

### 回滚机制

如果任何步骤失败，回滚已创建的内容：

```yaml
rollback:
  - 删除 AI-TASK/projects/{CODE}/ 目录
  - 删除 {SUB_PROJECT_PATH}/ai-task 软链接
  - 删除 {SUB_PROJECT_PATH}/CLAUDE.md
  - 删除 {SUB_PROJECT_PATH}/.claude/ 目录
  - 恢复父项目 project.yaml
```

### 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| 路径不存在 | 输入路径错误 | 检查路径拼写 |
| 未接入 AI-TASK | 父项目未初始化 | 先运行 init-project.sh |
| CODE 冲突 | 项目代号已存在 | 使用 --code 指定不同代号 |
| 权限不足 | 无写入权限 | 检查目录权限 |

## 帮助信息

```
/init_sub_project 命令用法:

  /init_sub_project <path>                    初始化子项目
  /init_sub_project <path> --code CODE        指定项目代号
  /init_sub_project <path> --name NAME        指定项目名称
  /init_sub_project <path> --tech "A, B"      指定技术栈
  /init_sub_project --help                    显示帮助

示例:
  /init_sub_project ./packages/core
  /init_sub_project ./modules/auth --code AUTH --name "认证模块"
  /init_sub_project ../shared-lib --tech "TypeScript, React"
```
