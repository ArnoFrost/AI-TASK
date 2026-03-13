# 贡献指南

感谢你对 AI-TASK 的关注！欢迎提交 Issue 和 Pull Request。

## 提交 Issue

### Bug 报告

请包含以下信息：

- **环境**：操作系统、IDE 版本
- **复现步骤**：详细的操作步骤
- **预期行为**：你期望发生什么
- **实际行为**：实际发生了什么
- **截图/日志**：如有相关截图或错误日志

### 功能建议

- 描述你希望添加的功能
- 说明使用场景和预期收益
- 如有参考实现，请附上链接

## 提交 Pull Request

### 开发流程

1. **Fork** 本仓库
2. **创建分支**：`git checkout -b feature/your-feature`
3. **提交更改**：遵循提交规范
4. **推送分支**：`git push origin feature/your-feature`
5. **创建 PR**：填写 PR 模板

### 提交信息规范

采用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]
```

| Type | 说明 | 中文等价 |
|------|------|---------|
| `feat` | 新功能 | 功能 |
| `fix` | Bug 修复 | 修复 |
| `docs` | 文档更新 | 文档 |
| `chore` | 构建/工具变更 | 杂务 |
| `refactor` | 代码重构 | 重构 |
| `style` | 代码格式 | 格式 |
| `perf` | 性能优化 | 性能 |
| `security` / `安全` | 安全相关 | 安全 |

> 本仓库实际使用中也接受中文 type（如 `完备(开源):`, `发版:`, `规范(核心):`），
> 保持与团队实际用法一致即可。

**示例**：

```
feat(skills): 添加 git-minimal-commit 技能
docs: 更新 README 徽章样式
fix(init): 修复软链接路径问题
发版: v1.5.0 — 架构精简与多IDE适配
```

### 代码规范

- Markdown 文件使用 UTF-8 编码
- 代码块标注语言类型
- 表格对齐使用空格
- 文件末尾保留一个空行

## 开发指南

### 目录结构

详见 [SPEC.md#架构概览](./SPEC.md#架构概览) 和 [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md#目录结构详解)。

### 添加新技能

`skills/` 在开源仓库中定位为**纯规范参考层**，每个技能目录包含 `SKILL.md` 描述文件（遵循 [agentskills.io](https://agentskills.io) 规范）。

可执行技能（斜杠命令等）通过**个人技能库**管理（如 `my-claude-skills/`），不纳入本仓库。

贡献新技能规范：

1. 在 `skills/` 下创建目录
2. 添加 `SKILL.md` 文件
3. 更新相关文档

### 添加新模板

1. 在 `templates/` 下创建文件
2. 更新 `templates/README.md`

## 开源边界

AI-TASK 采用**柔性分离**策略：开源仓库提供框架与规范，个人配置与数据由使用者本地管理。

| 层级 | 开源仓库 | 个人配置 |
|------|---------|---------|
| 模板 | `templates/` | — |
| 规范参考 | `skills/{name}/SKILL.md` | — |
| 可执行技能 | — | 个人技能库（如 `my-claude-skills/`） |
| 项目数据 | `projects/EXAMPLE/` 仅示例 | 其他 `projects/*`（gitignore 已忽略） |
| 自治空间 | — | `projects/AI-TASK/`（DDAC 自治理，不公开） |
| IDE 入口 | 根目录 `CODEBUDDY.md` | 各项目的 CLAUDE.md/AGENT.md（init 生成） |
| 软链接配置 | `relink.sh`（框架） | `relink.local.sh`（私有映射，gitignore） |
| 工具 | `tools/`、`init-project.sh` | — |

> **贡献者须知**：PR 不应包含个人项目数据、可执行技能实现或本地配置文件。
> 如需贡献新工具或模板，请确保其为通用性内容。

## 致谢

感谢所有贡献者的付出！
