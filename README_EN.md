<div align="center">

# AI-TASK

**A file/template-driven AI collaboration roadmap + task system for solo developers across many projects and devices**

English | [简体中文](./README.md)

[![GitHub stars](https://img.shields.io/github/stars/ArnoFrost/AI-TASK?style=flat-square&logo=github)](https://github.com/ArnoFrost/AI-TASK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ArnoFrost/AI-TASK?style=flat-square&logo=github)](https://github.com/ArnoFrost/AI-TASK/network)
[![GitHub last commit](https://img.shields.io/github/last-commit/ArnoFrost/AI-TASK?style=flat-square)](https://github.com/ArnoFrost/AI-TASK/commits)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-green.svg?style=flat-square)](CHANGELOG.md)
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
- [Task Tags](#-task-tags)
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
    subgraph DDAC["DDAC Methodology"]
        D1["Theory"]
        D2["4-Layer Arch"]
        D3["17 Meta-Prompts"]
    end

    subgraph AITASK_IMPL["AI-TASK Implementation"]
        A1["Project Structure"]
        A2["Task Templates"]
        A3["AGENT.md"]
    end

    D1 -->|guides| A1
    D2 -->|implements| A2
    D3 -->|applies| A3

    style DDAC fill:#e1f5fe,stroke:#90caf9
    style AITASK_IMPL fill:#fff3e0,stroke:#ffcc80
```

It is designed primarily for **solo developers** who work on many repositories and switch between devices (e.g., iCloud/drive sync), and want their AI assistant to follow the same workflow everywhere.

### Key features

| Feature | Description |
|:---:|---|
| 🗂️ | **Per-project space** - Each project lives under `projects/{CODE}/` |
| 🔗 | **Symlink integration** - Non-invasive via `ai-task/` mount point |
| 📱 | **Cross-device sync** - `project.yaml` supports multi-device paths |
| 🤖 | **Multi-IDE support** - Claude Code / CodeBuddy / Cursor / AGENT.md |
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

# Interactive mode (recommended)
./init-project.sh

# Or with arguments
./init-project.sh myapp --name "My App" --path "/path/to/myapp" --tech "React,TS"
```

### 3) Start collaborating

In your AI assistant, include the project entry:

```
@projects/MYAPP/index.md
Help me implement user login
```

> 💡 Slash commands are managed via personal skill libraries. See [skills/README.md](./skills/README.md)

---

## 📐 Architecture

```mermaid
graph TB
    subgraph REPO["AI-TASK Repository"]
        direction TB
        PROJECTS["projects/"]
        SKILLS["skills/"]
        TEMPLATES["templates/"]
        TOOLS["tools/"]

        subgraph SPACES["Project Spaces"]
            P1["PROJECT_A/"] --> P1T["tasks/"]
            P1 --> P1D["docs/"]
            P2["PROJECT_B/"] --> P2T["tasks/"]
            P2 --> P2D["docs/"]
        end

        PROJECTS --> P1
        PROJECTS --> P2
    end

    subgraph REAL["Your Repos"]
        EXT1["~/Projects/app-a/"]
        EXT2["~/Projects/app-b/"]
    end

    EXT1 -.->|"symlink"| P1
    EXT2 -.->|"symlink"| P2

    style REPO fill:#e1f5fe,stroke:#90caf9
    style SPACES fill:#fff3e0,stroke:#ffcc80
    style REAL fill:#f3e5f5,stroke:#ce93d8
```

---

## 📂 Directory Structure

```text
AI-TASK/
├── README.md / README_EN.md
├── SPEC.md
├── AGENT.md / CODEBUDDY.md    # AI collaboration entry (IDE adapters)
├── init-project.sh             # Interactive multi-IDE project init
├── projects/
│   └── {PROJECT}/
│       ├── project.yaml
│       ├── index.md
│       ├── tasks/
│       ├── docs/
│       └── archive/ (optional)
├── skills/                     # Spec references (pure spec layer)
├── rules/
├── templates/                  # Core templates
└── tools/                      # Utility scripts
```

---

## 📋 Task Tags

| Tag | Purpose | Tag | Purpose |
|-----|---------|-----|---------|
| `[功能]` | New feature | `[优化]` | Optimization |
| `[修复]` | Bug fix | `[排查]` | Investigation |
| `[文档]` | Documentation | `[调研]` | Research |
| `[技术方案]` | Technical design | `[规范]` | Standards |
| `[下线]` | Deprecation | `[清理]` | Cleanup |
| `[梳理]` | Analysis | `[测试]` | Testing |
| `[评审]` | Code review | `[架构]` | Architecture |
| `[集成]` | Integration | `[同步]` | Tech sync |

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
