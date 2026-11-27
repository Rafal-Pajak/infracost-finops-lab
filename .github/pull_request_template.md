## FinOps & Infrastructure Change Summary
* **Opportunity Register ID:** `OPT-XXX`
* **Target Environment:** `dev` / `staging` / `prod`
* **Change Category:** `Rightsizing` / `Storage Lifecycle` / `Orphaned Cleanup` / `Tagging Governance` / `Commitment Coverage`

### 1. Evidence-Based Cost Impact (`Infracost`)
> Paste the `infracost diff` output below before moving this PR out of Draft:

    # Paste infracost diff output here

* **Estimated Monthly Delta:** `-$XXX.XX / month` (`-XX%`)
* **Annualized Run-Rate Impact:** `-$X,XXX.XX / year`

### 2. SRE & Operational Risk Assessment
* [ ] Verified `terraform plan` output — **no unintended resource destruction/replacement (`-/+`)** on stateful components.
* [ ] Performance headroom validated (CPU/Memory/IOPS P95/P99 metrics reviewed; N+1 resilience preserved).
* [ ] Validated in `non-prod` environment prior to production promotion.
* [ ] Rollback plan documented (revert PR or restore previous SKU/tier).

### 3. Policy-as-Code & Tagging Compliance
* [ ] `terraform fmt -check` and `terraform validate` passed.
* [ ] `Checkov` security & tagging checks passed (mandatory tags: `Environment`, `Owner`, `CostCenter`, `Service`).
* [ ] `OPA / Rego` FinOps budget & SKU guardrails passed.

### 4. Client Governance & Explicit Sign-Off
> *Note: Production promotions and commercial commitments (Reserved Instances / Savings Plans) require explicit client approval. Realised savings depend on client sign-off, deployment timing, and workload usage.*

* [ ] **Client Technical / Change Approval:** `@client-owner`
* [ ] **Client Commercial / FinOps Approval (if applicable):** `@client-finops`
