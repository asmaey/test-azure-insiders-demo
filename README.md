# Azure Insiders Demo Repo 

This repository accompanies the Azure Insiders session:
"Accelerate your DevOps with AI: from code to intelligent deployment".

It is a hands-on demo project that intentionally includes common DevOps problems
so you can see how GitHub Copilot and GitHub/Azure automation help detect, fix,
and operationalize them.

## What You Will Learn

By exploring this project, you can practice how to:

1. Improve a slow, fragile CI/CD pipeline.
2. Fix a real SQL injection vulnerability.
3. Automate incident response from runbook-style operations.
4. Generate daily issue intelligence automatically with workflows.

## Demo Scenarios Included

| Scenario | Problem | Where to Look |
|---|---|---|
| Broken pipeline | Outdated runner/version and inefficient workflow design | `.github/workflows/deploy.yml` and `.github/workflows/deploy-fixed.yml` |
| Security bug | SQL injection in login endpoint | `app/app.py` (`/login`) and `ISSUES_SEED.md` issue 1 |
| Incident response | Manual, slow runbook process | `runbooks/incident-runbook.md` and `.github/workflows/incident-response.yml` |
| Daily operational summary | Manual triage does not scale | `.github/workflows/daily-issues-report.lock.yml` |

## Quick Start

### 1. Clone and install

```bash
git clone https://github.com/asmaey/test-azure-insiders-demo.git
cd test-azure-insiders-demo/app
pip install -r requirements.txt
```

### 2. Run the app

```bash
python app.py
```

The API starts on `http://localhost:5000`.

### 3. Verify health

```bash
curl http://localhost:5000/health
```

Expected response:

```json
{"status": "ok"}
```

## Reproduce the Main Learning Flows

### Flow A: Understand and Improve the Pipeline

1. Open `.github/workflows/deploy.yml`.
2. Identify bottlenecks and risks (outdated base image, old Python, no caching, no security stage).
3. Compare with `.github/workflows/deploy-fixed.yml` to see one possible modernization pattern.

### Flow B: Reproduce the Security Issue

The `/login` endpoint currently builds SQL using string interpolation. This is intentionally vulnerable.

Example payload:

```bash
curl -X POST http://localhost:5000/login \
   -H "Content-Type: application/json" \
      -d "{\"username\":\"admin' --\",\"password\":\"anything\"}"
```

Check `ISSUES_SEED.md` issue 1 for the full vulnerability report and remediation target.

### Flow C: Explore Incident Automation

1. Read `runbooks/incident-runbook.md` to see the manual process style.
2. Open `.github/workflows/incident-response.yml` to see how parts of incident handling can be automated.

### Flow D: Generate a Daily Issues Summary

Trigger the workflow manually from GitHub Actions:

1. Go to the Actions tab of your fork/repo.
2. Open "Daily Issues Report".
3. Click "Run workflow".

This demonstrates automated issue triage/reporting.

## Project Structure

```
test-azure-insiders-demo/
├── README.md
├── ISSUES_SEED.md
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py
├── infra/
│   └── main.bicep
└── runbooks/
      └── incident-runbook.md
```

## Important Notes

- This repository is intentionally insecure/incomplete in places for training and demo purposes.
- Do not use this code as-is in production.
- If you fork this repo, keep it private if you plan to run it with real credentials or integrations.

## Suggested Next Steps

1. Fix the SQL injection and add tests for `/login`.
2. Promote `deploy-fixed.yml` as your baseline pipeline.
3. Add dependency and secret scanning to your CI path.
4. Extend incident workflows with rollback and notification integrations.

Project created for Azure Insiders (April 2026), adapted for attendees.
