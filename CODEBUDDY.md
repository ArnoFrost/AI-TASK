# AI-TASK

> AI 协作任务管理系统 · v2.2.0

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 projects/{CODE}/tasks/ |
| 查看任务 | 查看 projects/{CODE}/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |
| 初始化项目 | `./init-project.sh`（交互式多 IDE 支持） |

## 标签

`[功能]` `[优化]` `[修复]` `[排查]` `[文档]` `[调研]` `[技术方案]` `[规范]` `[下线]` `[清理]` `[梳理]` `[测试]` `[评审]` `[架构]` `[集成]` `[同步]`

## ⚠️ 发版规范（MUST）

> **任何涉及版本号变更的 commit，必须遵守以下 checklist。AI 不得跳过任何一项。**

### 版本号更新

使用 `tools/bump-version.sh` 批量更新，**严禁手动逐文件改版本号**：

```bash
# 检查当前版本号一致性
./tools/bump-version.sh --check

# 预览变更
./tools/bump-version.sh X.Y.Z --dry-run

# 执行更新
./tools/bump-version.sh X.Y.Z
```

### 发版 Checklist

| # | 步骤 | 说明 |
|---|------|------|
| 1 | `./tools/bump-version.sh X.Y.Z` | 批量更新 README/CODEBUDDY/setup.sh 等版本号 |
| 2 | 编写 CHANGELOG.md | 手动编写发版记录（Added/Changed/Removed/Migration） |
| 3 | `./tools/bump-version.sh --check` | 确认所有位置版本号一致 ✅ |
| 4 | `git add -A && git commit` | 提交变更 |
| 5 | `git tag -a vX.Y.Z` | 打 annotated tag |
| 6 | `git push origin <branch> --tags` | 推送分支 + tag |

### 版本号语义

- **MAJOR** (X.0.0)：破坏性变更（如目录结构改变）
- **MINOR** (x.Y.0)：新功能（向后兼容）
- **PATCH** (x.y.Z)：Bug 修复 / 文档修正

## 快捷链接

| 文档 | 路径 |
|------|------|
| 全局规范 | [SPEC.md](./SPEC.md) |
| 项目列表 | [projects/](./projects/) |
| 模板库 | [templates/](./templates/) |
| 规范参考 | [skills/](./skills/) |
| 版本工具 | [tools/bump-version.sh](./tools/bump-version.sh) |
