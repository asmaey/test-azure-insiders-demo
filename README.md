# Azure Insiders Demo — Thomas vs Sisyphus

> **Session:** *Accelerate your DevOps with AI: from code to intelligent deployment*
> **Presenters:** Solution Engineer Software & Dev Productivity + Firas Mdimagh, CSA AI & Apps

---

## The Thomas Myth

Thomas is a DevOps engineer at a tech startup. Every week, he pushes his boulder up the mountain. And every Friday at 5pm, the boulder rolls back down.

Like Sisyphus, Thomas is condemned to start over. **But today, that changes.**

> *"One must imagine Sisyphus happy. We prefer to give him GitHub Copilot — and give him back his weekends."*

---

## Thomas's 4 Boulders

| # | The Boulder | The Pain | Tool That Breaks It |
|---|------------|----------|---------------------|
| 1 | **Pipeline broken on Friday** | Hand-written CI/CD, 18-min build, broken in prod | GitHub Copilot (VS Code) |
| 2 | **Bug detected in production** | SQL Injection vulnerability discovered by a client | GitHub Copilot Coding Agent |
| 3 | **Night incident, runbook page 47** | 2am, 2021 runbook, Jean-Claude left the team | Agentic Workflows (GitHub Actions) |
| 4 | **Manual deployment: 18 min, fingers crossed** | Post-deploy anomaly, Thomas is the on-call firefighter | Azure SRE Agent |

---

## The 4 Acts

### Act I — The Myth
Introduction of Thomas and the Sisyphus metaphor. The 4 universal DevOps pains. The audience recognizes Thomas — it might be them.

### Act II — The Boulder
Demonstration of the problem: broken pipeline, prod bug, unreadable runbook, risky deployment. Everything is real, everything is painful.

### Act III — The Copilot
GitHub Copilot enters the scene. Each boulder is broken, one by one, in real time in front of the audience.

### Act IV — The Curse Broken
Thomas is no longer the firefighter. He has become the **Reliability Architect**. Before/after metrics. Emotional conclusion.

---

## Presenter Split

| Segment | Who | Tool |
|---------|-----|-------|
| Intro — The Thomas Myth | SE | Slides |
| Boulder 1 — Pipeline fix | SE | Copilot in VS Code |
| Boulder 2 — Bug to auto PR | SE | Coding Agent |
| Boulder 3 — Incident workflow | SE to Firas (handoff) | Agentic Workflows |
| Boulder 4 — Azure SRE Agent | Firas | Azure SRE Agent |
| Conclusion — The curse broken | Both | Final slide |

---

## Demo Flow — Step-by-Step Instructions

### Prerequisites before the session
1. Fork or clone this repo to a visible GitHub account
2. Create the 3 issues from `ISSUES_SEED.md`
3. Assign Issue #1 (SQL Injection) to Copilot Coding Agent **10 min before** the demo (it will be working in the background)
4. Pre-run the `incident-response.yml` workflow and keep the logs open in a tab
5. Open VS Code with `app/app.py` and `.github/workflows/deploy.yml` ready

---

### Boulder 1 — Broken Pipeline (GitHub Copilot, ~5 min)

**Context to say:** *"Thomas wrote this pipeline on a Friday evening. Notice the comment at the top."*

1. Open `.github/workflows/deploy.yml` in VS Code
2. Show the problems: `ubuntu-18.04` runner, sequential jobs, `python 3.8`, no cache
3. Open **Copilot Chat**: *"Explain why this pipeline is suboptimal and suggest an optimized version"*
4. Copilot explains in plain language
5. Show `deploy-fixed.yml` as the result: parallel jobs, `ubuntu-latest`, pip cache, bandit scan
6. **Stat to announce: 18 min to 6 min, -67% build time**

**Punchline:** *"Thomas no longer searches through page 47 of the runbook. He just asks Copilot."*

---

### Boulder 2 — Prod Bug (Coding Agent, ~7 min)

**Context to say:** *"A client sent this payload at 3am. The team discovered the vulnerability in production."*

1. Open Issue #1 `[SECURITY] SQL Injection` in the browser
2. Show the example payload in the issue
3. Click **"Assign to Copilot"** on the issue (or show it is already assigned)
4. **Talk to the audience for 2-3 min** (Coding Agent works in the background)
5. Refresh to see Copilot has opened a **Pull Request** with:
   - The fix (parameterized query)
   - Missing tests for `/login`
   - A PR description explaining the remediation
6. Show the diff — highlight that Copilot added the tests

**Punchline:** *"Before, Thomas learned about the bug from an angry client. Now, Copilot fixes it while Thomas drinks his coffee."*

---

### Boulder 3 — Night Incident (Agentic Workflow, ~6 min)

**Context to say:** *"2am. An alert fires. Thomas opens the runbook. Page 1... page 23... page 47."*

1. Open `runbooks/incident-runbook.md` — quickly show the length and step 47
2. **Transition:** *"What if the workflow did this automatically?"*
3. Trigger `incident-response.yml` via workflow_dispatch (or show a completed run)
4. Walk through the steps: Detect, Correlate, Diagnose, Remediate, Report
5. Show the automatically created GitHub Issue with the structured incident report

**Punchline:** *"2am, Thomas is asleep. The workflow is already writing the post-mortem."*

---

### Boulder 4 — Azure SRE Agent (Firas, ~7 min)

*Handoff to Firas — see separate Azure SRE Agent script*

**Context to say:** *"The PR is merged, deployment is running. And then... an anomaly appears in Azure Monitor."*

---

## Project Structure

```
azure-insiders-demo/
├── README.md                           # This file
├── app/
│   ├── app.py                          # Flask app (with intentional vulnerability)
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py                 # Incomplete tests (for Coding Agent)
├── .github/
│   └── workflows/
│       ├── deploy.yml                  # BROKEN pipeline (Boulder 1)
│       ├── deploy-fixed.yml            # Fixed pipeline (post-Copilot)
│       └── incident-response.yml       # Agentic workflow (Boulder 3)
├── infra/
│   └── main.bicep                      # Azure infrastructure (App Service + SQL)
├── runbooks/
│   └── incident-runbook.md             # Outdated 2021 runbook (Boulder 3 — page 47)
└── ISSUES_SEED.md                      # Issues to create before the demo
```

---

## Before / After Metrics (for slides)

| Metric | Before (Thomas alone) | After (Thomas + GitHub AI) |
|--------|----------------------|---------------------------|
| CI build time | 18 min | 6 min (-67%) |
| Vulnerability fix time | 2 hours | < 10 min |
| Incident response time | 2 hours (night) | Automated |
| Manual deployment | 45 min | Supervised + auto-rollback |

---

*Project created for Azure Insiders — April 2026*
