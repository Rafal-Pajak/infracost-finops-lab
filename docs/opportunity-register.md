# FinOps Opportunity Register (Template & Lab Baseline)

This register tracks identified cloud cost optimisation opportunities, estimated financial value, engineering implementation effort, operational risk, and realised benefits.

> **Governance Principle:** Recommendations are delivered as peer-reviewed Infrastructure-as-Code Pull Requests with `Infracost` diff evidence. All production changes and commitment purchases (Reserved Instances / Savings Plans) remain strictly subject to explicit client approval.

## Summary Metrics (Current Cycle)
* **Total Identified Monthly Savings:** `$1,420.00 / mo` (`$17,040.00 / yr` annualized)
* **Approved & In-Progress:** `$610.00 / mo`
* **Realised to Date:** `$430.00 / mo`

---

## Active & Historical Opportunities

| ID | Cloud / Scope | Opportunity Description | Est. Monthly Savings | Est. Annual Savings | Implementation Effort | Risk Level | Status | PR / Evidence |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **OPT-001** | Azure (`dev-app`) | Rightsize over-provisioned non-prod VMs from `Standard_D4s_v5` to `Standard_B2ls_v2` based on 30-day P95 CPU < 12% | `$190.00` | `$2,280.00` | Low (1 PR, ~30 min) | Low | **Realised** | `Infracost` diff + Non-prod soak test |
| **OPT-002** | Azure (`shared-net`) | Remove 14 unattached Managed Disks (Premium SSD) and orphaned Public IPs post-migration | `$240.00` | `$2,880.00` | Low (1 PR, ~45 min) | Low | **Realised** | Snapshot backup taken before `destroy` |
| **OPT-003** | Azure (`finops-data`) | Enforce blob lifecycle policy (Cool after 30d, Archive after 90d, Delete after 365d) on FOCUS cost export & log storage | `$180.00` | `$2,160.00` | Low (1 PR, ~30 min) | Low | **Approved** | Awaiting client Change Window |
| **OPT-004** | AWS (`eks-prod`) | Rightsize Kubernetes worker node requests/limits and enable Karpenter consolidation for off-peak scaling | `$360.00` | `$4,320.00` | Medium (2 PRs, ~4 hrs) | Medium | **In Review** | Kubecost + P99 latency baseline |
| **OPT-005** | Multi-Cloud (`prod`) | Purchase 1-Year No-Upfront Compute Savings Plan covering 70% steady-state baseline across Azure & AWS | `$450.00` | `$5,400.00` | Low (Commercial sign-off) | Low | **Identified** | Coverage model ready for client CFO/FinOps |

---

## Status Lifecycle Definitions
1. **Identified:** Opportunity quantified via billing exports (`FOCUS`) or telemetry (`Azure Monitor` / `Cost Explorer`); awaiting technical triage.
2. **In Review:** Draft Pull Request created with `Infracost` cost delta, `Checkov`/`OPA` validation, and non-prod test plan.
3. **Approved:** Client stakeholder signed off on technical risk and change window (or commercial commitment).
4. **Realised:** Change promoted to production; post-deployment billing variance verified against baseline.
5. **Declined / Deferred:** Rejected due to performance/SLA constraints or upcoming architectural migration (rationale recorded).
