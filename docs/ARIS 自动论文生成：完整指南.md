# ARIS 自动论文生成：完整指南

## 一、端到端 Pipeline 概览

你有两条主要路径：

| 路径                 | 适用场景                            | 命令             |
| -------------------- | ----------------------------------- | ---------------- |
| `/research-pipeline` | 从零开始：方向 → idea → 实验 → 论文 | 全自动，一条命令 |
| `/paper-writing`     | 已有实验结果，只需写论文            | 半自动           |

---

## 二、各阶段自动化程度分析

### 完全可自动化（放心让我跑）

| 阶段         | Skill                                               | 说明                  |
| ------------ | --------------------------------------------------- | --------------------- |
| 文献调研     | `/research-lit`, `/arxiv`, `/semantic-scholar`      | 搜索、下载、总结      |
| Idea 生成    | `/idea-creator`                                     | 生成+排序             |
| 查新         | `/novelty-check`                                    | 对比已有工作          |
| 论文大纲     | `/paper-plan`                                       | 结构化 outline        |
| LaTeX 撰写   | `/paper-write`                                      | 逐 section 生成       |
| 编译         | `/paper-compile`                                    | 修 LaTeX 错误         |
| 自动润色     | `/auto-paper-improvement-loop`                      | GPT-5.4 审稿→修改×2轮 |
| 图表生成     | `/paper-figure`, `/figure-spec`, `/mermaid-diagram` | 从数据到图            |
| 公式推导     | `/formula-derivation`, `/proof-writer`              | 理论部分              |
| 引用审计     | `/citation-audit`                                   | 检查引用真实性        |
| 数据声明审计 | `/paper-claim-audit`                                | 数字与原始结果对齐    |

### 需要人工干预的关键节点

| 阶段                | 原因                           | 你需要做什么                           |
| ------------------- | ------------------------------ | -------------------------------------- |
| **选择研究方向**    | 这是你的学术判断               | 给我一个明确方向                       |
| **Idea 筛选**       | 我生成5-10个，你选哪个做       | 看排序结果，选1-2个                    |
| **实验设计确认**    | 涉及计算资源、数据集可用性     | 确认 `/experiment-plan` 输出           |
| **实验执行监控**    | GPU 可能 OOM、训练发散         | 我会 `/training-check`，但异常需你决策 |
| **核心 claim 确认** | 结果支持什么结论是学术诚信问题 | 看 `/result-to-claim` 输出             |
| **投稿 venue 选择** | 影响格式、篇幅、风格           | 告诉我目标会议/期刊                    |
| **最终通读**        | AI 可能有幻觉或逻辑跳跃        | 最后读一遍                             |

---

## 三、最佳 Prompt 写法

### 差的写法 ❌
```
帮我写篇论文
```

### 好的写法 ✅

**一步到位型（全自动）：**
```
/research-pipeline 基于大语言模型的代码审查自动化

目标venue: ICSE 2027
我有4张A100可用，实验预算48小时
数据集：可用CodeReviewer和已有的内部数据
风格参考：附件中的ICSE 2025 best paper
```

**分步控制型（推荐）：**
```
第一步：/idea-discovery 大模型在软件工程中的应用，侧重代码审查

（看完结果后）
第二步：我选第3个idea，请 /research-refine 细化方案

（确认方案后）
第三步：/experiment-plan 生成实验计划

（确认计划后）
第四步：/run-experiment 部署到我的服务器 user@gpu-server

（实验完成后）
第五步：/paper-writing 从结果到论文，目标ICSE，style-ref: ./reference_paper.pdf
```

### Prompt 关键要素

1. **研究方向**（必须）：越具体越好
2. **目标 venue**（强烈建议）：决定格式、页数、风格
3. **资源约束**：GPU 数量、时间预算
4. **风格参考**（可选）：`— style-ref: <path>` 让输出模仿某篇论文风格
5. **排除条件**（可选）：不想用的方法、不想比的 baseline

---

## 四、主动调用 vs 被动调用

**推荐：主动调用关键节点，让我被动串联中间步骤。**

具体来说：

- **你主动调用**：`/research-pipeline`、`/idea-discovery`、`/paper-writing` 这些顶层 workflow
- **我被动调用**：workflow 内部会自动串联子 skill（如 `/paper-plan` → `/paper-figure` → `/paper-write` → `/paper-compile`）

你不需要手动调用每个子 skill，除非你想在某个环节精细控制。

---

## 五、实战最佳实践

### 1. 先跑 lite 再跑 full
```
/idea-discovery 你的方向
```
先看 idea 质量，再决定是否投入实验资源。

### 2. 用 `/result-to-claim` 做诚实性检查
实验跑完后，先让我判断结果能支撑什么 claim，再写论文。避免 overclaim。

### 3. 用 `/kill-argument` 做对抗审稿
论文写完后跑一次，模拟最严厉的 reviewer 攻击，提前补洞。

### 4. 用 `/citation-audit` 防幻觉引用
AI 写的论文最大风险是引用不存在的论文。这个 skill 会逐条验证。

### 5. 多轮润色用 `— effort: beast`
```
/auto-paper-improvement-loop ./paper — style-ref: ./best_paper.pdf
```

### 6. 保存研究知识库
```
/research-wiki init
```
跨 session 积累论文、idea、实验结果的关联关系。

---

## 六、一个完整的"睡前一键"示例

如果你想睡前启动、醒来收论文：

```
/research-pipeline 面向长上下文LLM的高效注意力机制

约束：
- 目标: NeurIPS 2027
- GPU: 8×H100, 可用72小时
- 必须比较: FlashAttention-3, Ring Attention, Inf-LM
- 数据集: LongBench, RULER
- style-ref: ./reference_neurips_paper.pdf
- 写完后自动跑 /kill-argument 和 /citation-audit
```

这会触发完整 pipeline：文献→idea→查新→细化→实验计划→实验→结果分析→论文撰写→编译→润色→审计。

---

## 七、风险提醒

| 风险               | 缓解措施                                   |
| ------------------ | ------------------------------------------ |
| 引用幻觉           | `/citation-audit` 必跑                     |
| 数据造假（非故意） | `/experiment-audit` + `/paper-claim-audit` |
| 实验不充分         | `/ablation-planner` 补充消融实验           |
| 写作风格机械       | `— style-ref` 指定参考论文                 |
| 逻辑跳跃           | `/kill-argument` 暴露弱点                  |

---

## 总结

**你负责方向选择、idea 筛选、claim 确认这三个学术判断节点，其余全部可以交给 ARIS 自动完成。** Prompt 写得越具体（venue、资源、baseline、风格参考），输出质量越高。