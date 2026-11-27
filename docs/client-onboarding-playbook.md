# FinOps-as-a-Service: 30-Day Client Onboarding Playbook

A structured, low-friction framework for onboarding new enterprise accounts into continuous FinOps governance without disrupting engineering velocity or production SLAs.

> **Operating Boundaries:** All infrastructure changes are proposed via peer-reviewed Pull Requests (`Infracost` + `Checkov`/`OPA` validated) and tested in `non-prod` first. Production deployments and commercial commitments (Reserved Instances / Savings Plans) require explicit client approval.

---

## Phase 1: Visibility & Billing Foundation (Days 1–7)
**Objective:** Establish a single source of truth for multi-cloud spend and map technical resources to business ownership.

1. **Billing Data Ingestion (`FOCUS` Standard):**
   * Configure automated daily `FOCUS` (FinOps Open Cost and Usage Specification) exports in Parquet format to dedicated, lifecycle-managed storage (`examples/azure-multisite-finops`).
   * Verify multi-currency / multi-country billing hierarchy mapping (`Billing Account` -> `Billing Profile` -> `Invoice Section` in Azure MCA; AWS Organizations / Linked Accounts).
2. **Tagging & Allocation Baseline:**
   * Audit existing tag coverage against core allocation keys: `Environment`, `Owner`, `CostCenter`, and `Service`.
   * Separate **shared platform costs** (Transit Gateways, Firewalls, Shared AKS/EKS clusters) from direct application workloads to define showback/chargeback rules.
3. **Shift-Left Guardrails Audit:**
   * Assess existing CI/CD pipelines for IaC cost visibility (`Infracost`) and policy enforcement (`OPA/Rego`, `Checkov`).

**Deliverable:** Baseline Spend & Tagging Coverage Report + `FOCUS` export pipeline live.

---

## Phase 2: Zero-Risk Quick Wins & Hygiene (Days 8–15)
**Objective:** Capture immediate, non-disruptive savings while building trust with client SRE and Platform teams.

1. **Orphaned & Idle Resource Cleanup:**
   * Identify unattached managed disks, idle load balancers, obsolete snapshots, and unassociated static public IPs.
   * Take point-in-time snapshots before proposing cleanup via IaC Pull Requests.
2. **Non-Production Scheduling:**
   * Implement automated off-hours snoozing (nights/weekends) for `dev` and `qa` compute and database tiers where safe.
3. **Storage Tiering & Retention:**
   * Apply automated blob/object lifecycle policies (Hot -> Cool -> Archive -> Expire) on telemetry, backup, and billing export buckets.

**Deliverable:** First batch of `OPT-XXX` entries logged in `docs/opportunity-register.md` and submitted as Draft PRs.

---

## Phase 3: Workload Rightsizing & Commitment Strategy (Days 16–30)
**Objective:** Optimize active production run-rate using telemetry-backed engineering and commercial levers.

1. **Telemetry-Driven Rightsizing:**
   * Analyze 30-day CPU, Memory, Disk IOPS, and Network throughput (`P95` / `P99` percentiles) to identify over-provisioned VMs, databases, and Kubernetes node pools.
   * Validate target SKUs (e.g., migrating legacy `D-series` to modern `B2ls_v2` / Graviton / AMD equivalents) in `non-prod` load tests before proposing production PRs.
2. **Steady-State Commitment Modeling:**
   * Separate volatile burst traffic from predictable 24/7 baseline compute.
   * Model 1-Year No-Upfront `Savings Plans` or `Reserved Instances` targeting 65–75% baseline coverage (preserving flexibility for architectural modernization).
3. **Governance Handover & Cadence:**
   * Enable automated PR cost-gates (`.github/pull_request_template.md`) for ongoing engineering changes.
   * Establish bi-weekly FinOps review cadence tracking *Identified -> Approved -> Realised* savings with client Finance and Engineering leads.

**Deliverable:** 30-Day Executive FinOps Review, Commitment Coverage Proposal (for client sign-off), and active `Shift-Left` PR workflow.
