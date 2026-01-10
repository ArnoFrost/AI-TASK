---
name: git-minimal-commit
description: |
  代码变动整理技能。帮助清理无用修改、最小化提交范围、整理 commit 历史、拆分大型提交。
  Use when: 整理提交、最小化提交、清理修改、git 整理、代码变动、去掉无用修改、commit 整理
---

# 代码变动整理技能

## 🎯 能力范围

- 识别并清理无用修改
- 分离不相关的变更
- 最小化提交范围
- 整理 commit message
- 拆分大型提交

## 📐 变更分类

### 无用修改类型

| 类型 | 示例 | 处理方式 |
|------|------|----------|
| 空白变更 | 仅空格/换行变化 | `git checkout -- file` |
| 格式化噪音 | IDE 自动格式化 | 还原或单独提交 |
| 调试代码 | `console.log`, `print` | 删除 |
| 注释代码 | 被注释的旧代码 | 删除 |
| 无关文件 | `.idea/`, `.DS_Store` | 加入 `.gitignore` |
| import 排序 | 仅 import 顺序变化 | 还原或单独提交 |

### 变更分离原则

```
✅ 单一职责: 一个 commit 只做一件事
✅ 原子性: 每个 commit 可独立回滚
✅ 可追溯: commit message 清晰描述变更
```

## 🔧 操作流程

### 1. 查看当前变更

```bash
# 查看所有变更文件
git status

# 查看详细 diff
git diff

# 查看已暂存的变更
git diff --cached

# 按文件查看变更
git diff -- path/to/file
```

### 2. 识别无用修改

```bash
# 查看空白变更
git diff -w  # 忽略空白差异

# 对比忽略空白后的差异
git diff -w --stat
```

### 3. 清理无用修改

```bash
# 还原单个文件
git checkout -- path/to/file

# 还原所有空白变更（保留实际修改）
git diff -w > changes.patch
git checkout .
git apply changes.patch

# 交互式还原部分变更
git checkout -p -- path/to/file
```

### 4. 分离变更

```bash
# 交互式暂存
git add -p

# 选项说明:
# y - 暂存此块
# n - 不暂存此块
# s - 拆分成更小的块
# e - 手动编辑此块
# q - 退出
```

### 5. 整理提交

```bash
# 修改最后一次提交
git commit --amend

# 交互式 rebase 整理多个提交
git rebase -i HEAD~n

# rebase 选项:
# pick - 保留提交
# reword - 修改 message
# squash - 合并到前一个提交
# fixup - 合并但丢弃 message
# drop - 删除提交
```

## 📋 Commit Message 规范

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| refactor | 重构（非新功能/修复） |
| style | 格式调整（不影响代码逻辑） |
| docs | 文档变更 |
| test | 测试相关 |
| chore | 构建/工具变更 |
| perf | 性能优化 |

### 示例

```
feat(carousel): 添加焦点图熔断机制

- 新增 RecompositionCircuitBreaker 类
- 检测连续重组次数超过阈值时触发熔断
- 添加熔断状态日志

Closes #123
```

## 🔍 检查清单

### 提交前检查

- [ ] 无调试代码 (`console.log`, `print`, `Log.d`)
- [ ] 无注释掉的代码块
- [ ] 无无关文件变更
- [ ] 无纯空白/格式变更（或已单独提交）
- [ ] commit message 符合规范
- [ ] 变更范围最小化

### 常见问题处理

#### 误提交了文件

```bash
# 从暂存区移除（保留本地文件）
git reset HEAD -- path/to/file

# 从最后一次提交中移除
git reset HEAD~1 -- path/to/file
git commit --amend
```

#### 需要拆分提交

```bash
# 软重置到需要拆分的提交之前
git reset --soft HEAD~1

# 重新分批提交
git add -p
git commit -m "第一部分"
git add -p
git commit -m "第二部分"
```

#### 合并多个小提交

```bash
git rebase -i HEAD~n
# 将后续提交标记为 squash 或 fixup
```

## 📊 输出示例

```markdown
## 变更整理报告

### 原始变更
- 文件数: 15
- 新增行: 500
- 删除行: 200

### 清理后
- 文件数: 8
- 新增行: 320
- 删除行: 150

### 清理内容
| 文件 | 操作 | 原因 |
|------|------|------|
| A.kt | 还原 | 仅空白变更 |
| B.kt | 部分还原 | 移除调试日志 |
| .idea/xxx | 还原 | IDE 配置文件 |

### 建议提交拆分
1. `feat(xxx): 核心功能实现` - 5 files
2. `refactor(xxx): 代码优化` - 2 files
3. `style(xxx): 格式调整` - 1 file
```
