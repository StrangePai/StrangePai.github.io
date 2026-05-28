# 寫作與語法參考

## 哲學

**精簡但深邃。AI秒懂。**

- 每一行都要有份量。不要灌水，不要重複。
- 寫給 AI 看——密度高、結構化、pattern-matchable（可被模式比對）。
- 專有名詞第一次出現盡可能用英文（中文補充） 格式寫，後續重複出現不再加。
- SKILL.md 不超過 500 行。做不到 → 拆解。
- 細節寫進子檔案（lazy-load 延遲載入，零 context 上下文成本）。

## Frontmatter（前置資料區）

```yaml
---
name: skill-name
description: WHEN 觸發——Claude 用這欄做匹配。寫得像搜尋查詢。
argument-hint: [arg]                    # 自動補齊提示 (動作參數)
allowed-tools: Read, Grep, Bash         # 自動核可的工具
# 可見性：
#   default                            → user ✓  auto-load ✓
#   disable-model-invocation: true     → user ✓  auto-load ✗  （有副作用！）
#   user-invocable: false              → user ✗  auto-load ✓  （內部 lib）
# 隔離：
#   context: fork                      → subagent（子代理），全新 context（fork = 分叉，開全新獨立記憶）
#   agent: Explore                     → subagent 類型（需要 context: fork）
---
```

## Body 變數

`$ARGUMENTS` 全部 · `$0 $1 $2` 位置參數 · `${CLAUDE_SKILL_DIR}` skill 目錄 · `` `cmd` `` shell 注入

## Scope（作用範圍）

`.claude/skills/` 專案層級 > `~/.claude/skills/` 全域
