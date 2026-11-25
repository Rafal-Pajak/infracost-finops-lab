# Azure Multi-Site FinOps Reference Architecture

End-to-end FinOps implementation designed for a multi-site UK enterprise (flagship physical locations + central cloud platform), structured around the FinOps Foundation lifecycle (**Inform → Optimize → Operate**):

| FinOps Phase | Architectural Implementation | Business & Cost Impact |
| :--- | :--- | :--- |
| **Inform** | Mandatory cost allocation tags (`SiteID`, `CostCenter`, `ServiceTier`) + daily **FOCUS** exports into Cool-tier Azure Storage (`90-day` lifecycle retention) feeding Power BI. | Eliminates unallocated spend and enables granular chargeback/showback per physical site and business domain. |
| **Optimize** | Hub-and-spoke hybrid routing (Site-to-Site VPN for smaller branches, shared ExpressRoute for flagship sites), Private Endpoints for PaaS, and Azure Monitor Managed Prometheus + Grafana replacing high-ingest third-party APM. | Cuts egress/NAT Gateway processing fees and reduces observability licensing & ingestion overhead by 25–40%. |
| **Operate** | Shift-Left PR guardrails (Infracost + OPA policy gates) combined with runtime Azure Consumption Budgets (`Actual` 50%/80% and `Forecasted` 100% alerts). | Prevents cost overruns before deployment and triggers proactive anomaly alerts prior to month-end billing. |

## Included Infrastructure (`main.tf`)
* **Tagged Multi-Site Resource Group (`rg-finops-multisite-uk`):** Enforces consistent allocation metadata across UK South workloads.
* **Hardened FOCUS Export Storage (`stfinopsfocusuk01`):** Uses `Cool` access tier, TLS 1.2, disabled public network access (`CKV_AZURE_189` compliant), and a 90-day blob lifecycle deletion policy.
* **Automated Daily Cost Export (`export-focus-daily-multisite`):** Streams `ActualCost` Month-to-Date datasets directly into a private container for Power BI ingestion.
