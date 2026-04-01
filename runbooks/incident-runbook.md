# Production Runbook -- v1.2 -- Last updated: January 2021

> **WARNING:** This document is the authoritative source for production incident handling.
> For questions, contact Jean-Claude (NOTE: Jean-Claude left the team in March 2022. Try Thomas.)
> This runbook applies to all production services. Some sections may reference deprecated tools.
> Dead link archive: http://internal-wiki/ops/runbooks (server decommissioned Q3 2021)

---

## Table of Contents

1. Prerequisites
2. Initial Triage
3. Escalation Procedures
4. Service-Specific Steps
5. Rollback Procedures (see step 47)

---

## Prerequisites

Before starting any incident response, ensure you have:
- VPN access (see internal IT portal -- link changed, ask someone who knows)
- SSH keys for production servers (stored in the shared drive, folder SSH KEYS PROD FINAL v3)
- Legacy monitoring dashboard: http://grafana-old.internal (might be down, try the new one)
- PagerDuty account (billing expired March 2021, we use email alerts now)

---

## Steps

**1.** Check if you are the on-call engineer. If not, wake up the on-call engineer anyway.

**2.** Open the monitoring dashboard. If it is down, open a second incident for the monitoring dashboard being down.

**3.** Log into the production jumpbox: ssh ops@jumpbox-prod-01.internal (password on sticky note on Jean-Claude's old desk).

**4.** Check system load: uptime. If load average > 2.0, proceed to step 12. If > 10.0, proceed to step 31. If unreachable, proceed to step 8.

**5.** Check disk usage: df -h. If any partition is above 80%, proceed to step 17. If /var/log is above 95%, run the log rotation script (see step 19 for caveats).

**6.** Check available memory: free -m. Document the value in the incident log spreadsheet (http://sharepoint.internal/ops/incidents -- requires IE11).

**7.** Verify the application process is running: ps aux | grep gunicorn. If no process found, proceed to step 23. If multiple, proceed to step 27.

**8.** If jumpbox unreachable, try backup: ssh ops@jumpbox-prod-02.internal. If also unreachable, call the datacenter hotline (number on the whiteboard in the old office, we moved in 2022).

**9.** Check network connectivity: ping 8.8.8.8. If no response, escalate to infrastructure team (Slack #infra -- archived since we moved to Teams).

**10.** Review application logs: tail -f /var/log/app/production.log. If file missing, check /opt/app/logs/ or /home/deploy/logs/ depending on deployment method.

**11.** Check the database connection (see shared KeePass file for credentials). NOTE: migrated to PostgreSQL in 2020 but some services still use old MySQL config.

**12.** If high load: identify top CPU process with top. If application server -> step 15. If database query -> step 33. If cron job -> see step 41.

**13.** Check load balancer: log into HAProxy admin at http://lb-prod.internal:1936 (credentials: admin/admin -- yes, we know, it is on the backlog).

**14.** Review deployment log: cat /var/log/deployments.log. If missing, check Git history manually (deployment log script lost in server migration).

**15.** Restart application gracefully: sudo systemctl restart gunicorn-app. Wait 30 seconds. If issue persists -> step 16. If service fails to start -> step 24.

**16.** Force restart: terminate all gunicorn processes by PID (use lsof or ps to find PIDs), wait 5 seconds, then sudo systemctl start gunicorn-app. This causes ~2 min downtime.

**17.** Free disk space: sudo find /var/log -name "*.log.gz" -mtime +30 -delete. Check again. If still critical -> step 20. WARNING: do NOT delete /var/log/audit/ -- compliance requirement.

**18.** Archive old logs to S3: aws s3 sync /var/log/app/archive/ s3://our-log-archive-bucket/ (bucket was renamed in 2021, update command if you get 404).

**19.** The log rotation script /opt/scripts/rotate_logs.sh has a known bug: deletes logs < 24h old if run between midnight and 1am. Avoid that window. Bug reported in JIRA-4521 (JIRA decommissioned).

**20.** If disk still critical: du -sh /* 2>/dev/null | sort -rh | head -20. Common culprits: core dumps in /tmp, old Docker images, database WAL files.

**21.** Docker disk issues: docker system prune -af. WARNING: removes all stopped containers, unused images, and build cache. Confirm with team first.

**22.** Contact cloud provider support if infrastructure issues suspected: https://portal.azure.com (credentials managed by Finance, contact Marie-Christine -- also left the team, try Pierre).

**23.** If application process not running: sudo systemctl is-enabled gunicorn-app. Enable if disabled. Check logs: sudo journalctl -u gunicorn-app -n 100.

**24.** Service fails to start: check /etc/app/config.yml. Common issues: database connection string, missing env vars, port in use (check: sudo lsof -i :8000).

**25.** Check env vars: sudo cat /etc/app/.env. Verify DATABASE_URL, SECRET_KEY, REDIS_URL. Note: REDIS_URL may point to deprecated Redis 4 instance.

**26.** If port 8000 in use: sudo lsof -i :8000 to identify the process. Terminate the old process using its PID. Document this.

**27.** Multiple gunicorn processes: if more than 4 master processes, something is wrong. Terminate all gunicorn processes by PID, wait 10 seconds, then sudo systemctl start gunicorn-app.

**28.** Check application health: curl http://localhost:8000/health. Expected: {"status": "ok"}. If error or timeout, check application logs.

**29.** Database connectivity check: curl http://localhost:8000/db-check. NOTE: endpoint removed in v2.3. For versions >= 2.3, check logs instead.

**30.** Reverse proxy config: sudo nginx -t or sudo apachectl configtest. Reload: sudo systemctl reload nginx. Note: some services use Apache, migration to nginx was never completed.

**31.** Load average > 10: CRITICAL. Notify the CTO immediately. Then investigate: ps aux --sort=-%cpu | head -20.

**32.** Enable maintenance mode: modify load balancer config (step 13) or touch /var/www/maintenance.flag (only works if implemented -- added v2.1, removed v2.4 by mistake, re-added v2.6).

**33.** Database bottleneck: check active queries in PostgreSQL: SELECT pid, query, state FROM pg_stat_activity WHERE state != 'idle'; or MySQL: SHOW PROCESSLIST;

**34.** Terminate long-running database queries using pg_terminate_backend(pid) for PostgreSQL or KILL QUERY pid for MySQL. Document every query you terminate.

**35.** Check for database locks: SELECT * FROM pg_locks WHERE NOT granted; If locks present, identify blocking query and terminate it. Be careful -- wrong termination can corrupt data.

**36.** Enable slow query logging if not active (requires DB restart -- needs DBA approval, which is currently just Thomas).

**37.** Check Redis: redis-cli ping. If down, restart: sudo systemctl restart redis. Flushing cache (FLUSHALL) will cause temporary performance hit as cache warms up.

**38.** Review config changes: git log --oneline -10 in /opt/app-config/. Note: config and code were merged/split/merged again between 2020-2022. Check both repos if change not found.

**39.** Check scheduled jobs: crontab -l, sudo crontab -l, /etc/cron.d/, /etc/cron.daily/. Known issue: data export at 2am locks database for up to 20 minutes.

**40.** Check SSL cert expiry: openssl s_client -connect api.production.com:443 2>/dev/null | openssl x509 -noout -dates. Let's Encrypt renewal cron sometimes fails silently.

**41.** Known problematic cron jobs:
   - 0 2 * * * -- data export to S3 (can lock database, see step 39)
   - */5 * * * * -- health check script that sometimes spawns zombie processes
   - 0 3 * * 0 -- weekly cleanup (deprecated, still running, nobody remembers why)
   - 30 1 * * * -- log rotation (see step 19 for the bug)

**42.** Customer-facing incident: update status page at https://status.internal (SSO migration partial, ask for fallback credentials).

**43.** Incident communication template was in Confluence (decommissioned), exported to Word, saved on Jean-Claude's laptop.

**44.** Escalation contacts (in order):
   - Level 1: On-call engineer (you, right now, at 2am)
   - Level 2: Thomas (mobile: see on-call schedule spreadsheet)
   - Level 3: Jean-Claude (NOT AVAILABLE -- left March 2022, contact Thomas)
   - Level 4: CTO (mobile: emergency contacts document, printed copy in office, second drawer)

**45.** Last resort: reboot the production server (~5 min downtime). Requires approval from two engineers. Command: sudo reboot. Do NOT run sudo shutdown -h now.

**46.** Post-incident: fill out incident report (Confluence decommissioned, see step 43). Schedule post-mortem within 48 hours. Update incident log spreadsheet.

---

## Step 47 -- The Actual Useful Step

> **This is what you actually needed. Everything above was to make sure you understood the system.**

### Rollback to the previous deployment



> **Note:** If you got here after reading all 46 previous steps at 2am, consider using the
> Agentic Incident Response workflow (.github/workflows/incident-response.yml) instead.
> It reaches this step automatically in under 2 minutes.

---

*Runbook v1.2 -- Last updated January 2021 -- Next review scheduled Q2 2021 (never happened)*
*Owner: Jean-Claude Bertrand (departed March 2022)*
*For runbook updates, contact Thomas (who already has too many things to do)*
