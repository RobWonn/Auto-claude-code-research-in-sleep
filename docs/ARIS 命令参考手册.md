# ARIS 命令参考手册

> 所有 `/skill-name` 命令的使用说明和参数速查

## 命令格式

```
/skill-name "参数内容" — key: value, key2: value2
```

注意：`—` 是**长破折号**（em dash），不是短横线 `-`。

## 全局通用参数

以下参数适用于几乎所有 skill：

| 参数               | 值                                    | 默认       | 说明                               |
| ------------------ | ------------------------------------- | ---------- | ---------------------------------- |
| `effort`           | `lite` / `balanced` / `max` / `beast` | `balanced` | 工作强度（影响搜索量、审稿轮数等） |
| `human checkpoint` | `true` / `false`                      | `false`    | 每步暂停等你确认                   |
| `AUTO_PROCEED`     | `true` / `false`                      | `true`     | 是否在关键节点自动继续             |

---

## 一、全自动管线

### `/research-pipeline` — 从 idea 到论文一条龙

```
/research-pipeline "研究方向描述"
```

**做了什么：** idea-discovery → 实现代码 → 跑实验 → 自动审稿 → (可选)写论文

**参数：**

| 参数               | 值                          | 默认     | 说明                             |
| ------------------ | --------------------------- | -------- | -------------------------------- |
| `AUTO_PROCEED`     | `true`/`false`              | `true`   | `false` = Gate 1 等你选 idea     |
| `human checkpoint` | `true`/`false`              | `false`  | 审稿循环每轮暂停                 |
| `difficulty`       | `medium`/`hard`/`nightmare` | `medium` | 审稿严格程度                     |
| `auto_write`       | `true`/`false`              | `false`  | 自动进入写论文流程               |
| `venue`            | `ICLR`/`NeurIPS`/...        | `ICLR`   | 目标会议（auto_write=true 时用） |
| `ARXIV_DOWNLOAD`   | `true`/`false`              | `false`  | 下载相关 arXiv PDF               |

**示例：**

```
# 最简（全自动，选最优 idea）
/research-pipeline "点云补全中的扩散模型"

# 保守（等你选 idea，审稿时暂停，最终自动写论文）
/research-pipeline "点云补全" — AUTO_PROCEED: false, human checkpoint: true, auto_write: true, venue: NeurIPS

# 最严格审稿
/research-pipeline "3D点云" — difficulty: nightmare
```

**输出文件：**
- `idea-stage/IDEA_REPORT.md` — idea 报告
- `review-stage/AUTO_REVIEW.md` — 审稿记录
- `NARRATIVE_REPORT.md` — 叙事报告
- `paper/main.pdf` — 最终论文（仅 auto_write=true）

---

## 二、Workflow 1：Idea 发现

### `/idea-discovery` — Idea 发现全流程

```
/idea-discovery "研究方向"
```

**做了什么：** research-lit → idea-creator → novelty-check → research-review → research-refine-pipeline

**参数：**

| 参数             | 值             | 默认    | 说明                 |
| ---------------- | -------------- | ------- | -------------------- |
| `AUTO_PROCEED`   | `true`/`false` | `true`  | 自动选最优 idea 继续 |
| `ARXIV_DOWNLOAD` | `true`/`false` | `false` | 下载 arXiv PDF       |
| `COMPACT`        | `true`/`false` | `false` | 生成精简版输出       |
| `ref paper`      | URL 或本地路径 | -       | 参考论文             |

**示例：**

```
/idea-discovery "无监督点云补全"
/idea-discovery "3D视觉" — ref paper: https://arxiv.org/abs/2406.04329
/idea-discovery "扩散模型" — AUTO_PROCEED: false, ARXIV_DOWNLOAD: true
```

**输出：** `idea-stage/IDEA_REPORT.md`

---

### `/research-lit` — 文献搜索与综述

```
/research-lit "搜索主题"
```

**做了什么：** 搜索 Zotero → Obsidian → 本地 PDF → Web → (可选)Semantic Scholar / DeepXiv / Exa / Gemini / OpenAlex

**参数：**

| 参数             | 值                                                           | 默认      | 说明           |
| ---------------- | ------------------------------------------------------------ | --------- | -------------- |
| `sources`        | `all`/`web`/`zotero`/`local`/`semantic-scholar`/`deepxiv`/`exa`/`gemini`/`openalex` 组合 | `all`     | 搜索源         |
| `arxiv download` | `true`/`false`                                               | `false`   | 下载 arXiv PDF |
| `max download`   | 数字                                                         | `5`       | 最大下载数     |
| `paper library`  | 路径                                                         | `papers/` | 本地论文目录   |

**示例：**

```
/research-lit 点云补全最新论文
/research-lit "diffusion models for point cloud" — arxiv download: true
/research-lit "3D reconstruction" — sources: web, semantic-scholar
/research-lit "topic" — sources: all, deepxiv, max download: 10
```

**输出：** 终端输出文献表格 + 叙述综述。如有 `research-wiki/`，自动写入 wiki。

---

### `/idea-creator` — Idea 生成与排序

```
/idea-creator "研究方向"
```

**做了什么：** 头脑风暴生成多个 idea → pilot 实验验证 → 排序

**输出：** `idea-stage/IDEA_REPORT.md`

---

### `/novelty-check` — 新颖性检查

```
/novelty-check "你的方法描述"
```

**做了什么：** 提取核心技术声明 → 多源文献搜索 → GPT 交叉验证

**输出：** 每个声明的新颖性判定（NOVEL / INCREMENTAL / EXISTS）

---

### `/research-review` — 深度研究评审

```
/research-review "你的研究内容描述"
```

**做了什么：** GPT-5.4 xhigh 多轮深度评审

**输出：** 详细评审意见（优势、弱点、建议）

---

## 三、Workflow 2：自动审稿循环

### `/auto-review-loop` — 自动迭代改进

```
/auto-review-loop "研究内容描述"
```

**做了什么：** GPT 审稿 → 实现修改 → 跑新实验 → 重新审稿，最多 4 轮

**参数：**

| 参数               | 值                          | 默认     | 说明         |
| ------------------ | --------------------------- | -------- | ------------ |
| `difficulty`       | `medium`/`hard`/`nightmare` | `medium` | 审稿严格度   |
| `human checkpoint` | `true`/`false`              | `false`  | 每轮暂停     |
| `COMPACT`          | `true`/`false`              | `false`  | 精简恢复模式 |

**难度说明：**
- `medium`：标准审稿（GPT-5.4 xhigh）
- `hard`：加 Reviewer Memory（记住之前的批评）+ Debate Protocol（辩论）
- `nightmare`：加独立对抗审稿者，直接读代码验证声明

**输出：** `review-stage/AUTO_REVIEW.md`

---

## 四、Workflow 3：论文写作

### `/paper-writing` — 论文写作全流程

```
/paper-writing "NARRATIVE_REPORT.md"
```

**做了什么：** paper-plan → paper-figure → paper-write → paper-compile → auto-paper-improvement-loop

**参数：**

| 参数               | 值                                                           | 默认         | 说明             |
| ------------------ | ------------------------------------------------------------ | ------------ | ---------------- |
| `venue`            | `ICLR`/`NeurIPS`/`ICML`/`CVPR`/`ACL`/`AAAI`/`ACM`/`IEEE_JOURNAL`/`IEEE_CONF` | `ICLR`       | 目标期刊/会议    |
| `illustration`     | `figurespec`/`gemini`/`mermaid`/`false`                      | `figurespec` | 架构图引擎       |
| `human checkpoint` | `true`/`false`                                               | `false`      | 改进循环暂停     |
| `AUTO_PROCEED`     | `true`/`false`                                               | `true`       | 每阶段自动继续   |
| `effort`           | `lite`/`balanced`/`max`/`beast`                              | `balanced`   | 工作强度         |
| `assurance`        | `draft`/`submission`                                         | `draft`      | 提交质量保证级别 |

**示例：**

```
/paper-writing "NARRATIVE_REPORT.md" — venue: ICLR
/paper-writing "NARRATIVE_REPORT.md" — venue: IEEE_JOURNAL, illustration: gemini
/paper-writing "NARRATIVE_REPORT.md" — venue: NeurIPS, human checkpoint: true, effort: max
```

**输出：** `paper/` 目录，包含完整 LaTeX 源码和 `main.pdf`

---

### `/paper-plan` — 论文大纲

```
/paper-plan "研究主题或 NARRATIVE_REPORT.md"
```

**参数：** `venue` (默认 ICLR)

**输出：** `PAPER_PLAN.md`（Claims-Evidence Matrix + 章节规划 + 图表计划）

---

### `/paper-figure` — 数据图表生成

```
/paper-figure "PAPER_PLAN.md 或描述"
```

**能生成：** 折线图、柱状图、散点图、热力图、箱线图、多子图、LaTeX 表格

**不能生成：** 架构图、模型结构图、示意图（用 `/figure-spec` 或 `/paper-illustration`）

**输出：** `figures/` 目录下 PDF 图 + Python 脚本 + `latex_includes.tex`

---

### `/paper-illustration` — AI 生成学术插图

```
/paper-illustration "描述你想要的图"
```

**需要：** `GEMINI_API_KEY` 环境变量

**流程：** ARIS 规划 → Gemini 优化布局 → Gemini 验证风格 → Paperbanana 生成图片 → ARIS 评审 → 循环改进

**输出：** `figures/ai_generated/` 目录下 PNG 图 + LaTeX 片段

---

### `/figure-spec` — 确定性矢量架构图

```
/figure-spec "架构图/流程图描述"
```

**不需要 API Key。** 本地渲染 JSON → SVG。

**输出：** `figures/` 下 SVG 文件

---

### `/mermaid-diagram` — Mermaid 图

```
/mermaid-diagram "流程图/时序图描述"
```

**输出：** `figures/` 下 .mmd + .md 文件

---

### `/paper-write` — LaTeX 正文撰写

```
/paper-write "PAPER_PLAN.md"
```

**做了什么：** 逐章节生成 LaTeX → DBLP 获取真实引用 → 去 AI 腔润色 → GPT 交叉审稿

**输出：** `paper/sections/*.tex` + `paper/references.bib`

---

### `/paper-compile` — LaTeX 编译

```
/paper-compile "paper/"
```

**做了什么：** latexmk 编译 → 自动修错（最多 3 轮）→ 页数检查 → 提交准备检查

**输出：** `paper/main.pdf`

---

### `/auto-paper-improvement-loop` — 论文自动润色

```
/auto-paper-improvement-loop "paper/"
```

**做了什么：** Claude 审稿 → 按严重度修改 → 重编译，2 轮

**输出：**
- `paper/main_round0_original.pdf` — 原始版
- `paper/main_round1.pdf` — 第 1 轮改进
- `paper/main_round2.pdf` — 第 2 轮改进（最终版）
- `paper/PAPER_IMPROVEMENT_LOG.md` — 改进日志

---

## 五、后续工具

### `/paper-slides` — 生成演讲幻灯片

```
/paper-slides "paper/" — talk_type: oral, venue: ICML, minutes: 20
```

**输出：** `slides/` 目录下 Beamer PDF + PPTX + 演讲稿

---

### `/paper-poster` — 生成会议海报

```
/paper-poster "paper/" — venue: NeurIPS, size: A0, orientation: landscape
```

**输出：** `poster/` 目录下 LaTeX PDF + PPTX + SVG

---

### `/overleaf-sync` — Overleaf 同步

```
/overleaf-sync setup <project-id>    # 初始设置（需 Overleaf Premium）
/overleaf-sync pull                   # 拉取 Overleaf 修改
/overleaf-sync push                   # 推送本地修改
/overleaf-sync status                 # 查看差异
```

---

### `/rebuttal` — 回复审稿意见

```
/rebuttal "paper/ + 审稿意见"
```

**输出：** `PASTE_READY.txt`（可直接粘贴的回复）

---

## 六、辅助/审计工具

| 命令                          | 说明                              |
| ----------------------------- | --------------------------------- |
| `/experiment-audit`           | 交叉模型审计实验代码完整性        |
| `/result-to-claim`            | 判断实验结果是否支持声明          |
| `/paper-claim-audit "paper/"` | 审计论文中的数值声明 vs 原始数据  |
| `/citation-audit "paper/"`    | 审计所有引用的真实性和上下文      |
| `/analyze-results`            | 统计分析和对比表格                |
| `/ablation-planner`           | 设计审稿者视角的消融实验          |
| `/formula-derivation`         | 公式推导验证                      |
| `/proof-checker`              | 证明正确性检查                    |
| `/proof-writer`               | 生成形式化证明                    |
| `/research-wiki init`         | 初始化项目知识库                  |
| `/meta-optimize`              | 分析 skill 使用情况，提出改进建议 |

---

## 七、画图命令速查

| 需求                     | 用哪个命令            | 需要 API？            |
| ------------------------ | --------------------- | --------------------- |
| 折线图、柱状图、散点图   | `/paper-figure`       | 不需要                |
| 架构图、流水线图         | `/figure-spec`        | 不需要                |
| 流程图、时序图           | `/mermaid-diagram`    | 不需要                |
| AI 概念图、方法示意图    | `/paper-illustration` | 需要 `GEMINI_API_KEY` |
| Hero Figure / 手绘架构图 | 手动（draw.io/Figma） | -                     |

---

## 八、环境变量配置速查

| 变量                 | 用途                       | 必需？                  |
| -------------------- | -------------------------- | ----------------------- |
| `ANTHROPIC_API_KEY`  | Executor 模型（Claude）    | 是（aris 配置文件管理） |
| `OPENAI_API_KEY`     | Reviewer 模型（GPT-5.4）   | 是（aris 配置文件管理） |
| `GEMINI_API_KEY`     | `/paper-illustration` 画图 | 仅画图时需要            |
| `ANTHROPIC_BASE_URL` | 第三方 API 代理            | 使用代理时需要          |
| `ARIS_LANGUAGE`      | 输出语言                   | 否（配置文件管理）      |