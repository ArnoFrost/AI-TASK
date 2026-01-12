# 贡献指南

感谢你对 AI-TASK 的关注！欢迎提交 Issue 和 Pull Request。

## 🐛 提交 Issue

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

## 🔧 提交 Pull Request

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

| Type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `chore` | 构建/工具变更 |
| `refactor` | 代码重构 |
| `style` | 代码格式 |

**示例**：

```
feat(skills): 添加 git-minimal-commit 技能
docs: 更新 README 徽章样式
fix(init): 修复软链接路径问题
```

### 代码规范

- Markdown 文件使用 UTF-8 编码
- 代码块标注语言类型
- 表格对齐使用空格
- 文件末尾保留一个空行

## 📋 开发指南

### 目录结构

```
AI-TASK/
├── projects/      # 项目数据（不提交真实项目）
├── templates/     # 模板文件
├── skills/        # AI 技能
├── rules/         # 项目规则
└── .codebuddy/    # IDE 配置
```

### 添加新技能

1. 在 `skills/` 下创建目录
2. 添加 `SKILL.md` 文件（遵循 agentskills.io 规范）
3. 更新相关文档

### 添加新模板

1. 在 `templates/` 下创建文件
2. 更新 `templates/README.md`
3. 如需同步到子项目，更新 `sync-templates.sh`

## 🙏 致谢

感谢所有贡献者的付出！
