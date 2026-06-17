# Beisen Resume Auto-Merge Tool

[🌐 中文文档](README.md)

## 1. Overview

Beisen iTalent's recruitment system often creates duplicate candidate profiles from multiple sources (Feishu import, manual entry, headhunter referrals, job applications). While the system **detects** suspected duplicates, the frontend provides **no batch filter or merge capability**.

This tool automates the entire process: traversing the candidate list, detecting duplicates, and merging them.

| Feature | Description |
|---------|-------------|
| Suspect detection | Polls up to 15s for async "suspected" button; skips non-suspects in ~1s |
| Batch merge | Merges per candidate with tab switching + "..." dropdown for >7 items |
| Checkpoint/resume | Auto-saves progress on interruption; resumes seamlessly |
| Failure tracking | Failed merges archived by candidate name + ID + page number |

---

## 2. Requirements

- **OS**: Windows 10+
- **Node.js**: 18+
- **Network**: Must access Beisen iTalent

---

## 3. Installation

### Step 1: Install Node.js

Download from https://nodejs.org (LTS version). Verify with `node --version`.

### Step 2: Get the project

```bash
git clone https://github.com/your-username/beisen-resume-merge.git
cd beisen-resume-merge
```

### Step 3: Install dependencies

Double-click `install.bat`, or run:

```bash
npm install
```

### Step 4: Configure

Copy `.env.example` → `.env`, edit the URL:

```env
BEISEN_BASE_URL=https://your-company.italent.cn
```

> Credentials are entered manually during login — the script never stores passwords.

---

## 4. Usage

### Option A: Normal mode

Double-click `start.bat`. Browser opens — manually log in, navigate to the candidate list, then press **Enter** in the terminal.

### Option B: Headless mode

Double-click `start-headless.bat` (no visible browser, safe to lock screen).

### Option C: Restart from scratch

```bash
npm start -- --reset
```

---

## 5. Merge Logic

```
Open resume
  └─ Poll for "suspected" button
       ├─ None → close, next candidate (~1s)
       └─ Found → open modal
            ├─ Switch tab → compare → "Merge" → select card → confirm
            ├─ Close modal, reopen
            ├─ Switch to next tab → merge
            └─ Repeat until done
```

---

## 6. Logs

`logs/` directory:

| File | Purpose |
|------|---------|
| `merge-*.log` | Step-by-step operation log |
| `report-*.json` | Full summary (total, success, failed) |
| `report-*-failed.json` | Failures grouped by candidate name + ID |
| `progress.json` | Checkpoint state |

---

## 7. Project Structure

```
beisen-resume-merge/
├── .env.example                     ← Config template
├── .gitignore
├── install.bat / start.bat / start-headless.bat
├── README.md / README_EN.md
└── src/
    ├── index.ts      ← Main loop + checkpoint
    ├── auth.ts       ← Browser launch
    ├── navigator.ts  ← List nav, resume open/close
    ├── merger.ts     ← Core merge logic
    ├── config.ts     ← Selectors, timeouts
    ├── logger.ts     ← Logging + reports
    ├── progress.ts   ← Checkpoint persistence
    └── test-merge.ts ← Test mode
```

---

## 8. Checkpoint & Resume

Press `Ctrl+C` to stop safely. Progress saved to `logs/progress.json`. Edit it to jump to a specific page:

```json
{ "pageNum": 5, "candidateIndex": 7, "processedIds": [] }
```

---

## 9. FAQ

**Q: Merge keeps failing for candidates with many suspects?**
A: Check `logs/report-*-failed.json`. Most failures are async data refresh delays — the script continues automatically.

**Q: How to lock screen during a run?**
A: Use headless mode (`start-headless.bat`).

**Q: Which resume is kept?**
A: Default keeps the current applicant (left side). Content comparison is logged but auto-selection requires configuration.

---

## 10. Security

- `.env` excluded from Git
- Passwords entered manually, never stored
- Browser cookies stored locally in `browser-data/` (gitignored)
