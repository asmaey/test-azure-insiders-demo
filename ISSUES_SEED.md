# Issues to Create Before the Demo

Create these 3 GitHub Issues manually before the live session.
They set up the storytelling context for each boulder.

---

## Issue 1 — Boulder 2 (Coding Agent demo)

**Title:** `[SECURITY] SQL Injection vulnerability in /login endpoint — detected in production`

**Labels:** `bug`, `security`, `critical`

**Body:**

```
## Security Vulnerability Report

**Severity:** CRITICAL
**Affected component:** Authentication API
**Affected file:** `app/app.py`, function `login()`, line ~44
**Detected:** Production logs analysis — 2026-04-01 03:14 UTC

---

### Description

A SQL Injection vulnerability has been identified in the `/login` POST endpoint.
The endpoint constructs SQL queries using Python f-strings with unsanitized user input,
allowing an attacker to bypass authentication or extract data from the database.

---

### Vulnerable Code

```python
# app/app.py — line 44
query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
cursor.execute(query)  # 🚨 VULNERABLE: SQL Injection
```

---

### Evidence — Working Exploit

The following payload was used by an attacker in production at 03:14 UTC:

**Request:**
```
POST /login
Content-Type: application/json

{
  "username": "admin' --",
  "password": "anything"
}
```

**Result:** The attacker successfully authenticated as `admin` without knowing the password.
The SQL query becomes:
```sql
SELECT * FROM users WHERE username = 'admin' --' AND password = 'anything'
```
The `--` comment operator neutralizes the password check entirely.

---

### Business Impact

- **Authentication bypass:** Any user account can be accessed without a password
- **Data exfiltration risk:** The database contains user credentials and roles
- **Regulatory exposure:** Potential GDPR violation if user data is accessed
- **Reputational risk:** If exploited at scale, customer trust is destroyed

---

### Suggested Fix

Replace the raw f-string query with a parameterized query:

```python
# SECURE: use parameterized queries
query = "SELECT * FROM users WHERE username = ? AND password = ?"
cursor.execute(query, (username, password))
```

---

### Additional Context

- The `/login` endpoint has **zero test coverage** — no tests exist for authentication
- The Bandit security scanner would catch this as rule B608 (SQL injection)
- The current CI pipeline does not include a security scan step

**Priority:** Immediate fix required — do not merge any other changes until this is resolved.
```

---

## Issue 2 — Boulder 1 (Pipeline fix demo)

**Title:** `CI/CD pipeline is broken — deploy failing every Friday`

**Labels:** `bug`, `ci/cd`

**Body:**

```
## CI/CD Pipeline Failure

**Impact:** Every deployment attempt fails — the team cannot ship to production
**First observed:** Friday 2026-03-28 17:47 UTC
**Frequency:** Every push to main branch

---

### Error Log (from last failed run)

```
Run pytest app/tests/ -v
============================= test session starts ==============================
platform linux -- Python 3.8.18
collected 2 items

app/tests/test_app.py::test_health PASSED                               [ 50%]
app/tests/test_app.py::test_health_wrong_assertion FAILED               [100%]

================================= FAILURES ==================================
______________ test_health_wrong_assertion _______________

    def test_health_wrong_assertion(client):
        response = client.get("/health")
>       assert response.status_code == 999
E       AssertionError: assert 200 == 999

FAILED app/tests/test_app.py::test_health_wrong_assertion - AssertionError
========================= 1 failed, 1 passed in 0.23s =========================
Error: Process completed with exit code 1.
```

---

### Additional Problems Identified

Beyond the broken test, the pipeline has several structural issues:

1. **Deprecated runner:** `ubuntu-18.04` is EOL and will be removed soon
2. **Old Python version:** `python 3.8` reached end-of-life in October 2024
3. **No pip cache:** every run re-downloads all dependencies (~4 extra minutes)
4. **Sequential jobs:** lint, test, build, and deploy all run in a single job with no parallelism
5. **No security scanning:** no bandit, no SAST, no dependency vulnerability check
6. **Estimated total runtime:** 18 minutes for a change that takes 5 minutes to review

---

### Team Impact

- Developers are blocked from deploying on Fridays (or any day)
- The team has resorted to manually deploying by SSH "just this once"
- Three hotfixes in the last two weeks were deployed manually, with no audit trail
- Thomas spent 3 hours last Friday debugging the pipeline instead of shipping features

---

### Proposed Solution

Rewrite the pipeline with:
- `ubuntu-latest` runner
- Python 3.11
- Parallel jobs: lint, test, security-scan running simultaneously
- Pip dependency caching
- Bandit security scan
- Estimated new runtime: 6 minutes
```

---

## Issue 3 — Boulder 3 (Incident response demo)

**Title:** `[INCIDENT] Latency spike on /deploy endpoint after last deployment`

**Labels:** `incident`, `production`

**Body:**

```
## Production Incident — Latency Spike

**Status:** ONGOING
**Severity:** P2-High
**Affected endpoint:** `POST /deploy`
**Detection time:** 2026-04-01 02:47 UTC
**Last deployment SHA:** see recent commits

---

### Alert Details

Azure Monitor alert fired at 02:47 UTC:

```
ALERT: p99 latency exceeded threshold
Service: api-production
Endpoint: POST /deploy
Threshold: 1000ms
Current value: 4200ms
Duration: 8 minutes
```

---

### Metrics

| Metric | Before deployment | After deployment |
|--------|------------------|-----------------|
| p50 latency | 180ms | 890ms |
| p95 latency | 320ms | 2100ms |
| p99 latency | 410ms | 4200ms |
| Error rate | 0.1% | 0.8% |
| Throughput | 120 req/min | 95 req/min |

---

### Timeline

- `02:31 UTC` — Last deployment merged and pushed to main
- `02:38 UTC` — Deployment completed on Azure App Service
- `02:47 UTC` — Azure Monitor alert fires (latency spike)
- `02:47 UTC` — On-call engineer (Thomas) paged
- `02:49 UTC` — Thomas opens the runbook
- `03:14 UTC` — Thomas reaches step 47 of the runbook
- `03:15 UTC` — This issue created

---

### Hypothesis

The latency spike correlates directly with the last deployment. Possible causes:
1. The `time.sleep(2)` in the `/deploy` endpoint is now being hit more frequently
2. A new code path introduced in the last commit is slow
3. Database connection pool exhaustion

---

### Current State

Thomas is currently on page 23 of the incident runbook trying to find the rollback procedure.
The runbook is from January 2021. Jean-Claude, who wrote it, left the team in March 2022.

Rollback command is on page 47. Thomas will get there eventually.

---

### Expected Resolution

Rollback to the previous deployment using Azure App Service deployment slots.
See runbook step 47 (or just use the incident-response.yml workflow).
```
