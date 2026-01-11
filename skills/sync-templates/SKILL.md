---
name: sync-templates
description: |
  同步主仓模板配置到子项目。将 templates/project.yaml 中的新字段增量合并到各子项目。
  Use when: 模板同步、更新子仓配置、刷新项目规范、同步配置、sync templates
---

# 模板同步技能

## 🎯 能力范围

- 将主仓模板配置同步到子项目
- 支持增量合并（只补充缺失字段）
- 支持子仓跳过同步
- 支持子仓锁定特定字段

## 🔧 触发方式

### 方式一：脚本执行

```bash
# 同步所有项目
./sync-templates.sh

# 只同步指定项目
./sync-templates.sh dotfiles TVKMM

# 预览变更（不实际修改）
./sync-templates.sh --dry-run
```

### 方式二：AI 对话触发

```
同步模板到所有子项目
同步模板到 dotfiles 项目
预览模板同步变更
```

### 方式三：Git Hook（可选）

```bash
# .git/hooks/post-commit
./sync-templates.sh --dry-run
```

## 📐 同步配置

在子项目的 `project.yaml` 中配置同步行为：

```yaml
sync:
  # 是否接受同步
  enabled: true           # false = 跳过此项目
  
  # 同步策略
  strategy: "merge"       # merge | skip | force
  
  # 锁定字段（不被覆盖）
  locked_fields:
    - task_naming         # 保持子仓自己的命名规则
    - tech_stack          # 保持子仓自己的技术栈
```

## 📋 同步内容

| 字段 | 说明 |
|------|------|
| `task_naming` | 任务命名配置（format/pattern/seq_digits） |
| `sync` | 同步配置本身 |
| 未来新增字段 | 自动同步 |

## 🔄 执行流程

```
1. 读取 templates/project.yaml 作为基准
2. 遍历 projects/*/project.yaml
3. 检查 sync.enabled（false 则跳过）
4. 检查 sync.locked_fields（锁定字段不覆盖）
5. 增量合并缺失字段
6. 输出变更报告
```

## ✅ 使用示例

### 示例 1：同步所有项目

```bash
$ ./sync-templates.sh

[EXAMPLE]
  ✓ task_naming 已存在
  ✓ sync 配置已存在

[dotfiles]
  + 将添加 task_naming 配置
  + 将添加 sync 配置

统计: 总计 2 | 同步 1 | 跳过 0 | 失败 0
```

### 示例 2：子仓跳过同步

```yaml
# projects/EXAMPLE/project.yaml
sync:
  enabled: false  # 跳过同步，保持示例稳定
```

### 示例 3：子仓锁定字段

```yaml
# projects/dotfiles/project.yaml
sync:
  enabled: true
  locked_fields:
    - task_naming  # 保持 simple 格式，不被覆盖为 full
```

## 💡 注意事项

- 同步是**增量合并**，不会删除子仓已有的配置
- `locked_fields` 中的字段即使缺失也不会被添加
- 建议先用 `--dry-run` 预览变更再执行
- 脚本依赖 `yq` 工具（可选，无则使用简化处理）
