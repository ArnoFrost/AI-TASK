<div align="center">

# AI-TASK

**A file/template-driven AI collaboration roadmap + task system for solo developers across many projects and devices**

English | [简体中文](./README.md)

[![GitHub stars](https://img.shields.io/github/stars/ArnoFrost/AI-TASK?style=flat-square&logo=github)](https://github.com/ArnoFrost/AI-TASK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ArnoFrost/AI-TASK?style=flat-square&logo=github)](https://github.com/ArnoFrost/AI-TASK/network)
[![GitHub last commit](https://img.shields.io/github/last-commit/ArnoFrost/AI-TASK?style=flat-square)](https://github.com/ArnoFrost/AI-TASK/commits)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-green.svg?style=flat-square)](CHANGELOG.md)
[![DDAC](https://img.shields.io/badge/Powered%20by-DDAC-blueviolet?style=flat-square&logo=bookstack)](https://github.com/ArnoFrost/DDAC)

<p>
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="./SPEC.md">Spec</a> •
  <a href="./CHANGELOG.md">Changelog</a>
</p>

</div>

---

<details>
<summary>📖 Table of Contents</summary>

- [30-Second Demo](#-30-second-demo)
- [What is AI-TASK](#-what-is-ai-task)
- [Key Concepts](#-key-concepts-3-things)
- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [Directory Structure](#-directory-structure)
- [Known Limitations](#️-known-limitations-stay-small--sharp)
- [Contributing](#-contributing)

</details>

---

## ⚡ 30-Second Demo

**Don't want to read docs? Copy this to your AI assistant:**

```
Please create a task document using AI-TASK format:
- Project: DEMO
- Tag: [feature]
- Task: User Login Module
- Goals: 1. Login form UI  2. Form validation  3. API integration

Reference: https://github.com/ArnoFrost/AI-TASK/blob/main/projects/EXAMPLE/tasks/20260101-001_%5B功能%5D用户登录模块.md
```

AI will generate a standardized task document ✅ → This is the core value of AI-TASK: **Make AI output reusable collaboration documents in a unified format**

---

## 🎯 What is AI-TASK?

AI-TASK is a **file-system convention for AI collaboration**. It standardizes where your AI workflow artifacts live (tasks, designs, investigation notes, validations, conclusions) via a consistent directory structure, templates, Rules, and Skills—so you can reuse the same collaboration playbook across multiple projects.

> 💡 **Relationship with DDAC**: AI-TASK is a **practical implementation** of the [DDAC (Document-Driven AI Collaboration)](https://github.com/ArnoFrost/DDAC) methodology. DDAC defines the theoretical framework and four-layer architecture for document-driven AI collaboration, while AI-TASK is an MVP that applies these principles to "solo developer, multi-project task management". For the design philosophy, see DDAC; to get started hands-on, start here.

```mermaid
graph LR
    subgraph "DDAC Methodology"
        D1[📚 Theory]
        D2[🏗️ 4-Layer Arch]
        D3[📝 17 Meta-Prompts]
    end
    
    subgraph "AI-TASK Implementation"
        A1[📂 Project Structure]
        A2[⚡ Slash Commands]
        A3[📋 Task Templates]
    end
    
    D1 -->|guides| A1
    D2 -->|implements| A2
    D3 -->|applies| A3
    
    style D1 fill:#e1f5fe
    style D2 fill:#e1f5fe
    style D3 fill:#e1f5fe
    style A1 fill:#fff3e0
    style A2 fill:#fff3e0
    style A3 fill:#fff3e0
```

It is designed primarily for **solo developers** who work on many repositories and switch between devices (e.g., iCloud/drive sync), and want their AI assistant to follow the same workflow everywhere.

### Key features

| Feature | Description |
|:---:|---|
| 🗂️ | **Per-project space** - Each project lives under `projects/{CODE}/` |
| 🔗 | **Symlink integration** - Non-invasive via `ai-task/` mount point |
| 📱 | **Cross-device sync** - `project.yaml` supports multi-device paths |
| 🤖 | **AI native** - Built-in slash commands for CodeBuddy/Claude Code |
| 📐 | **Template-driven** - Consistent, predictable AI output |

### Fits / Doesn't fit

- **Fits**: solo (or tiny teams), multi-project, cross-device, willing to write structured Markdown.
- **Doesn't fit**: teams needing boards/notifications/permissions/assignments and platform-grade workflows.

---

## 🧠 Key Concepts (3 things)

- **`projects/{CODE}/`**: the per-project collaboration space (tasks/docs/archive/metadata).
- **`ai-task/` symlink**: a mount point inside your real repo so the AI can always find the same paths.
- **`project.yaml` multi-device paths**: list the same project's paths across devices.

### 🔄 DDAC Self-Governance

AI-TASK follows the self-governance principles of [DDAC methodology](https://github.com/ArnoFrost/DDAC):

| Principle | Description |
|-----------|-------------|
| **Project Self-Space** | `projects/{PROJECT}/` manages its own tasks |
| **Tasks Must Be Documented** | Discussion plans → `tasks/` task documents |
| **Status Must Be Updated** | Task completion → update `index.md` task list |

**Task Documentation Triggers** (create task if any applies):
- User proposes multi-step optimization/improvement plan
- User includes `@projects/{PROJECT}/index.md` context
- Discussion involves 3+ file modifications
- User mentions "plan", "design", "proposal", "improve"

See [SPEC.md#ddac-self-governance](./SPEC.md#-ddac-自治理规范) for details.

---

## 🚀 Quick Start

### 1) Clone

```bash
git clone https://github.com/ArnoFrost/AI-TASK.git ~/AI-TASK
```

### 2) Initialize a project space

```bash
cd ~/AI-TASK
./init-project.sh MYAPP "My App" "/Users/xxx/Projects/myapp" "React, TypeScript"

# Or interactive mode
./init-project.sh
```

### 3) Use commands in your AI assistant

```
/task create [feature] User Login Module
/task list
/status
```

---

## 📐 Architecture

```mermaid
graph TB
    subgraph "AI-TASK Repository"
        AITASK[AI-TASK/]
        PROJECTS[projects/]
        SKILLS[skills/]
        RULES[rules/]
        TEMPLATES[templates/]

        AITASK --> PROJECTS
        AITASK --> SKILLS
        AITASK --> RULES
        AITASK --> TEMPLATES

        subgraph "Project Spaces"
            P1[PROJECT_A/]
            P2[PROJECT_B/]
            P1 --> P1T[tasks/]
            P1 --> P1D[docs/]
            P2 --> P2T[tasks/]
            P2 --> P2D[docs/]
        end

        PROJECTS --> P1
        PROJECTS --> P2
    end

    subgraph "Your Repos"
        EXT1[~/Projects/app-a/]
        EXT2[~/Projects/app-b/]

        EXT1 -.->|symlink| P1
        EXT2 -.->|symlink| P2
    end

    style AITASK fill:#e1f5fe
    style PROJECTS fill:#fff3e0
    style SKILLS fill:#f3e5f5
```

---

## 📂 Directory Structure

```text
AI-TASK/
├── README.md
├── README_EN.md
├── SPEC.md
├── init-project.sh
├── projects/
│   └── {PROJECT}/
│       ├── project.yaml
│       ├── index.md
│       ├── tasks/
│       ├── docs/
│       └── archive/ (optional)
├── skills/
├── rules/
├── templates/
└── .codebuddy/commands/
```

---

## ⚠️ Known limitations (stay small & sharp)

- **Cross-device sync conflicts**: avoid editing the same task file on two devices at the same time; if your drive creates conflict copies, merge manually.
- **Symlink differences**: best on macOS/Linux; Windows may require extra permissions/modes.
- **Not a team task platform**: no boards/permissions/assignments.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

<div align="center">

Made with ❤️ by [ArnoFrost](https://github.com/ArnoFrost)

[![GitHub](https://img.shields.io/badge/GitHub-ArnoFrost-181717?style=flat-square&logo=github)](https://github.com/ArnoFrost)

</div>
