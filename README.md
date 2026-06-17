# 北森疑似简历自动合并工具

[🌐 English Documentation](README_EN.md)

## 一、项目概述

北森 iTalent 招聘系统中，同一候选人经常出现多份重复简历（飞书导入、后台手动新建、猎头推荐、网申投递等渠道各自创建）。系统虽然提供了「疑似重复简历」检测功能，但前端**不支持按疑似简历筛选和批量合并**。

本工具自动遍历候选人列表，检测并合并所有疑似重复简历。

| 功能 | 说明 |
|------|------|
| 疑似检测 | 异步轮询等待「疑似」按钮渲染（最多 15 秒），无标记者 1 秒跳过 |
| 批量合并 | 每位候选人逐条合并，支持超过 7 条时展开「...」下拉 |
| 断点续跑 | 中断后自动从上次位置继续，不重复处理 |
| 失败追踪 | 失败记录按「姓名 + 编号 + 页码」归档，方便返工 |

---

## 二、环境要求

- **操作系统**：Windows 10 或以上
- **Node.js**：18 或以上版本
- **网络**：需能访问北森 iTalent 系统

---

## 三、首次安装

### 步骤 1：安装 Node.js（如已安装可跳过）

1. 访问 https://nodejs.org
2. 下载 LTS 版本，一路下一步安装
3. 安装完成后，打开 PowerShell 或 cmd，输入 `node --version` 确认安装成功

### 步骤 2：获取项目文件

```bash
git clone https://github.com/your-username/beisen-resume-merge.git
cd beisen-resume-merge
```

或者下载 ZIP 解压到本地。

### 步骤 3：安装依赖

双击 `install.bat`，等待完成。或手动运行：

```bash
npm install
```

### 步骤 4：修改配置

1. 将 `.env.example` 复制一份并重命名为 `.env`
2. 用记事本打开 `.env`，填入北森系统地址：

```env
BEISEN_BASE_URL=https://your-company.italent.cn
```

> **注意**：`.env` 已被 `.gitignore` 排除，不会被提交到 Git。账号密码由你手动登录时输入。

---

## 四、运行方式

### 方式 A：普通模式（推荐）

**双击 `start.bat`**，浏览器会自动打开北森页面。

操作步骤：
1. 浏览器打开后，**手动登录**北森系统
2. 手动导航到「应聘者」列表页
3. 回到命令窗口，按 **Enter**
4. 脚本接管，自动遍历合并

### 方式 B：无头模式（锁屏后继续跑）

**双击 `start-headless.bat`**，浏览器不可见，适合长时间挂机。

或使用命令行：

```bash
npm run start:headless
```

### 方式 C：从头开始

```bash
npm start -- --reset
```

清除所有断点和日志，从第 1 页第 1 个候选人重新开始。

---

## 五、合并逻辑说明

脚本对每位候选人的处理流程：

```
打开简历
  └─ 等待「疑似」按钮出现（轮询 15 秒）
       ├─ 无疑似 → 关闭简历，处理下一人（约 1 秒）
       └─ 有疑似 → 打开弹窗
            ├─ 切换 Tab → 比较内容 → 点「与TA合并」→ 选卡 → 确定
            ├─ 关闭弹窗，重新打开
            ├─ 切到下一个 Tab → 合并
            └─ ... 重复至全部合并完成
```

| 步骤 | 说明 |
|------|------|
| 疑似检测 | 异步渲染，脚本轮询等待真实数字出现 |
| Tab 切换 | 按索引点击；超过 7 个时先展开「...」下拉 |
| 内容比较 | 比较两侧简历文本量，日志记录但不自动换选 |
| 合并确认 | 自动识别弹窗中的左右卡片，点击确定 |

---

## 六、运行日志

日志保存在 `logs/` 目录：

| 文件 | 用途 |
|------|------|
| `merge-YYYYMMDD-HHMMSS.log` | 每一步操作日志 |
| `report-YYYYMMDD-HHMMSS.json` | 完整统计报告 |
| `report-YYYYMMDD-HHMMSS-failed.json` | 失败清单（按姓名+编号分组） |
| `progress.json` | 断点续跑进度 |

### 报告格式示例

```json
{
  "candidateTotal": 314,
  "candidateWithSuspect": 65,
  "candidatesMerged": 64,
  "mergeSuccess": 143,
  "mergeFailed": 86
}
```

### 失败清单格式

按「姓名 (编号)」分组，方便定位需要返工的候选人：

```json
{
  "赵竟 (C00191541)": {
    "name": "赵竟 (C00191541)",
    "failures": [
      { "suspectIndex": 2, "error": "Node is either not clickable..." },
      { "suspectIndex": 3, "error": "Node is either not clickable..." }
    ]
  }
}
```

---

## 七、项目文件结构

```
beisen-resume-merge/
├── .env.example                     ← 配置模板
├── .gitignore                       ← Git 忽略规则
├── install.bat                      ← 双击安装依赖
├── start.bat                        ← 双击启动（普通模式）
├── start-headless.bat               ← 双击启动（无头模式）
├── README.md                        ← 本文档
├── README_EN.md                     ← 英文文档
├── package.json
├── tsconfig.json
└── src/
    ├── index.ts                     ← 主入口（翻页循环 + 断点续跑）
    ├── auth.ts                      ← 启动浏览器 + 等待手动登录
    ├── navigator.ts                 ← 列表导航、打开/关闭简历
    ├── merger.ts                    ← 合并核心逻辑
    ├── config.ts                    ← CSS 选择器、超时配置
    ├── logger.ts                    ← 日志输出 + 统计报告
    ├── progress.ts                  ← 断点持久化
    └── test-merge.ts                ← 测试模式（连接已有浏览器）
```

---

## 八、断点续跑

运行中可按 `Ctrl+C` 安全退出，进度自动保存。下次运行自动从断点继续。

也可以手动编辑 `logs/progress.json` 跳到指定位置：

```json
{
  "pageNum": 5,           // 第几页
  "candidateIndex": 7,    // 页内第几个人（从 0 开始）
  "processedIds": []      // 已处理候选人 ID
}
```

---

## 九、常见问题

### Q1：运行后报错「npm 不是内部命令」
**A**：Node.js 未安装或未添加到 PATH。重新安装 Node.js，安装时勾选「Add to PATH」。

### Q2：登录后脚本不开始
**A**：确认已经手动导航到了「应聘者」列表页，然后回到命令窗口按 Enter。

### Q3：脚本一直卡在某个候选人
**A**：可能是网络波动或页面加载慢。耐心等待 30 秒，脚本会自动跳过继续下一个。

### Q4：合并失败很多
**A**：打开 `logs/report-*-failed.json` 查看失败清单。多数失败是因为异步数据未刷新，脚本会自动跳过不影响后续。

### Q5：锁屏后脚本停了
**A**：用 `start-headless.bat` 无头模式启动，锁屏不影响运行。

### Q6：想从某一页开始
**A**：编辑 `logs/progress.json`，修改 `pageNum` 和 `candidateIndex`，然后正常运行 `npm start`。

### Q7：合并选择保留哪份简历？
**A**：默认保留当前应聘者（左侧）。脚本会比较大两侧内容量并记录日志，如需要自动选右侧需调整 `compareResumeContent` 函数。

---

## 十、安全提醒

- `.env` 中包含北森系统地址，请勿通过邮件、微信分享
- 账号密码由你手动登录时输入，脚本不会保存明文密码
- 浏览器数据（Cookie）保存在本地 `browser-data/` 目录，已被 `.gitignore` 排除
