---
name: agent-claude-skills-guideline
description: 建立 Claude Code skills（SKILL.md）的指引文件。當你在開發、組織、或除錯自訂 skills / slash commands 時使用。
version: 0.8.1
---

# Skills = Library Dependencies（函式庫依賴）

skill 就是一個 lib（函式庫），照 lib 的方式設計：

- **SKILL.md = public API（對外公開介面）** — 永遠載入，保持精簡
- **子檔案 = 實作細節** — lazy-load（延遲載入），沒被 `Read` 之前不耗 context（上下文／對話記憶）
- **`Skill(name)` = import（匯入）** — skill 之間像 import 一樣組合
- **`user-invocable: false` = private package（私有套件）** — 內部 lib，不開放給使用者

不要把所有東西塞進 SKILL.md。**依載入頻率切割，不是依主題切割**。

## 實際範例

```
developing-programming/        # 含 3 個模組的 lib
├── SKILL.md                   # public API：流程概覽
└── reference/                 # lazy-load 子檔一律收這裡
    ├── developing.md          # 實作：test/format/lint/commit 步驟
    └── writelog.md            # 實作：changelog/版本邏輯

agent-claude-bot/              # 含子套件的 lib
├── SKILL.md                   # public API：bot 概覽 + 規則
├── reference/                 # 一般 lazy-load 子檔
├── plan/                      # 子套件：規劃階段（自帶結構，例外）
└── example-scripts/           # 子套件：參考腳本（自帶結構，例外）

developing-project-management/ # 含 lazy deps（延遲依賴）的 lib
├── SKILL.md                   # public API：每日 ticket 操作
└── reference/
    ├── setup.md               # lazy deps：首次專案初始化
    └── endpoints.md           # lazy deps：完整 API 參考
```

## Infrastructure（基礎建設）用 rule-based（規則導向），不要用 LLM

當你在設計協調 LLM workers（在背景跑任務的 LLM 工人）的腳本時：

- **Infrastructure 用 rule-based（bash/python）** — PM 狀態更新、git commit/merge、文件記錄、ticket 查詢。deterministic（同樣輸入永遠得到同樣結果），不會幻覺。
- **LLM 只做 creative（需要創造判斷）的工作** — 讀程式碼、寫實作、除錯。

### 把工具包裝成 bash helper（bash 輔助函式）

```bash
# 好：bash helper，永遠正確
pm_set_status() {
  curl -s -X PUT ".../rows/${ROW_NUMBER}" -d '{"row_data": ...}'
}

# 壞：叫 LLM 自己寫 curl
step "update-status" "Update PM status to in_progress via curl PUT..."
```

### 範例：orchestrator（協調器）= 純 rule-based

`orchestrator.sh` — **完全沒有 LLM**。純 bash + python：
- 查 PM API 的 todo tickets
- 派發給 workers
- 監控 timeout（逾時）
- 收集結果

### 範例：worker（工人）= bash 基建 + LLM 寫程式

`worker.sh` — bash 處理 git/PM，LLM 寫程式：
```
bash: pm_set_status "in_progress"     ← deterministic
bash: pm_append_doc "Started"         ← deterministic
LLM:  step "implement" "..."          ← creative（讀 + 寫程式）
bash: pm_set_status "testing"         ← deterministic
LLM:  step "test" "..."               ← creative（跑 + 修測試）
bash: git add && git commit           ← deterministic
bash: pm_set_status "done"            ← deterministic
```

**理由：** `POST` vs `PUT`、curl flag（curl 命令的參數）對不對、git merge 順序——這些不能交給 LLM，它會幻覺。bash 是 deterministic。

## 規則

1. **任何修改都必須 bump version（升版本號）。** 每個 SKILL.md 的 frontmatter（前置資料區）都有 `version:`。修 bug 用 patch（修補版，例：0.1.1），加功能用 minor（次要版，例：0.2.0）。**沒有例外。**
2. **SKILL.md 不超過 500 行。** 超過就拆分或拆解。
3. **依載入頻率切割。** 永遠載入 → SKILL.md。只用一次 → `reference/setup.md`。需要時才查 → `reference/{name}.md`。
4. **子檔案放 `reference/`，kebab-case 英文檔名。** 除了 SKILL.md 本身，所有 .md 子檔一律收在 `reference/` 資料夾、檔名小寫連字號（例：`brand-marketing.md`、`pas-3h.md`）。例外：自帶結構的子套件（含多檔的 plan/、example-scripts/）可保留自己的資料夾名。
5. **子檔案 = 零 context 成本**——除非被明確 read。
6. **Infra 用 rule-based，寫程式用 LLM。** 永遠不要叫 LLM 跑 git、PM、或 curl 來更新狀態。
7. **精簡但深邃。AI秒懂。** 每一行都要有份量，不要灌水。

語法／frontmatter 細節參考 [reference/creating.md](reference/creating.md)。

拆／合／改 skill 架構（含接力鏈握手位置改動）時，AI 自動跑 [reference/restructuring.md](reference/restructuring.md) 的閉環 checklist 並回報結果——使用者只看回報、做決策，不照表自查。
