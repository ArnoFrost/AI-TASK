# Changelog

所有重要变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [1.3.0] - 2026-02-03

### Added
- **三层架构演进**
  - 核心能力层 `skills/`：对齐 agentskills.io 规范
  - 共享命令层 `templates/shared-commands/`：IDE 无关的命令逻辑
  - IDE 适配层 `templates/{ide}/commands/`：IDE 特定语法适配
- **init_sub_project 命令增强**
  - 新增 `README.md` 自动生成（协作规范）
  - 新增软链接自动创建（`--path` 参数）
  - 支持从路径自动提取项目代号
- **全局任务编号规则**
  - 任务编号全局递增（跨日期），不再按日期重置
  - 模板和命令统一强制执行

### Changed
- **Skills 索引完善**：`skills/README.md` 补全 5 个技能（sync-templates, ddac-governance）
- **命令文件架构调整**：IDE 命令文件保留完整逻辑（不再使用引用方式）
- **项目结构精简**：`projects/AI-TASK/` 演进任务不再公开，仅保留入口文件

### Fixed
- **修复 .codebuddy/commands/ 同步问题**：运行层与模板层版本不一致导致命令执行不完整
- **修复 README.md 未生成问题**：旧版 init_sub_project 缺少 README.md 生成步骤

### Security
- AI-TASK 内部演进任务脱敏处理，只公开 EXAMPLE 作为示例项目

---

## [1.2.0] - 2026-01-12

### Added
- **README 极客化优化**
  - 新增 GitHub stars/forks/last-commit 动态徽章
  - 新增 DDAC Powered 徽章（flat-square 风格统一）
  - 添加快速导航条和可折叠目录结构
  - 特性列表改为表格化展示
  - Footer 添加作者社交链接
- **开源规范完善**
  - 新增 `templates/README.md` 模板库说明
  - 新增 `CONTRIBUTING.md` 贡献指南
  - 新增 `.github/ISSUE_TEMPLATE/` Issue 模板
  - 新增 `.github/PULL_REQUEST_TEMPLATE.md` PR 模板

### Changed
- **CODEBUDDY.md** 精简为 IDE 速查卡（Token < 500）
- **.gitignore** 通用化配置：`projects/*/` 通配忽略，仅保留 `!projects/EXAMPLE/`
- **EXAMPLE 模板** 同步 `task_naming` + `sync` 配置块

### Fixed
- 版本号统一：所有文档版本号对齐为 v1.2.0

---

## [1.1.1] - 2026-01-11

### Added
- **DDAC 关联说明**：README 新增与 [DDAC](https://github.com/ArnoFrost/DDAC) 方法论的关系说明
  - AI-TASK 是 DDAC 理论框架的落地实现 / MVP

### Fixed
- 统一代码块语法：`SPEC.md`、`CODEBUDDY.md` 中无标记代码块改为 `text` 类型

---

## [1.1.0] - 2026-01-11

### Added
- **任务命名可配置化**：`project.yaml` 新增 `task_naming` 配置块
  - 支持 4 种命名格式：`full`（默认）、`date`、`simple`、`custom`
  - 可自定义序号位数（`seq_digits`）
- **模板同步机制**：新增 `sync-templates.sh` 脚本
  - 支持主仓模板增量同步到子仓
  - 支持 `--dry-run` 预览变更
  - 子仓可通过 `sync.enabled: false` 跳过同步
  - 子仓可通过 `sync.locked_fields` 锁定特定字段
- **sync-templates Skill**：`skills/sync-templates/SKILL.md`
- **斜杠命令版本控制**：`.codebuddy/commands/` 和 `.codebuddy/rules/` 纳入 Git 跟踪

### Changed
- 更新 `SPEC.md` 任务命名规范文档
- 更新 `templates/project.yaml` 增加 `task_naming` 和 `sync` 配置示例
- 更新 `.codebuddy/commands/task.md` 支持读取项目配置决定命名格式

### Fixed
- 修复 `README.md` 和 `README_EN.md` 中 Mermaid 图表语法错误

### Security
- 从 Git 历史中移除敏感项目数据（`projects/` 下的真实项目）
- 更新 `.gitignore` 保护隐私数据

---

## [1.0.0] - 2026-01-10

### Added
- **首个开源版本**
- 软链接架构：非侵入式接入现有项目
- 多 IDE 支持：CodeBuddy / Claude Code 斜杠命令模板
- Skills 技能系统：对齐 agentskills.io 规范
- Rules 规则系统：项目级约定与规范
- 跨设备路径映射：`project.yaml` 支持多设备路径
- 双语 README（中文 / English）
- Mermaid 架构图

---

## 版本说明

| 版本号 | 说明 |
|--------|------|
| `MAJOR` | 不兼容的架构变更 |
| `MINOR` | 新增功能（向后兼容） |
| `PATCH` | Bug 修复（向后兼容） |

---

[1.3.0]: https://github.com/ArnoFrost/AI-TASK/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/ArnoFrost/AI-TASK/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/ArnoFrost/AI-TASK/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/ArnoFrost/AI-TASK/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ArnoFrost/AI-TASK/releases/tag/v1.0.0
