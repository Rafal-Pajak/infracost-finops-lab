# Multi-Cloud Shift-Left FinOps & DevSecOps Lab

Repozytorium demonstracyjne łączące estymację kosztów chmurowych oraz wymuszanie polityk FinOps/Security przed wdrożeniem infrastruktury (AWS, Azure, GCP):

- **Infracost (`infracost.yml`)** – wycena zmian IaC (koszty stałe + `infracost-usage.yml`).
- **Checkov (`custom_checks/`)** – walidacja bezpieczeństwa oraz wymuszanie tagów/etykiet kosztowych (`Environment`, `Owner`, `CostCenter`).
- **Open Policy Agent (`policies/finops_guardrails.rego`)** – twarde bramki budżetowe na poziomie zasobów.
- **Pre-commit & GitHub Actions** – automatyczna weryfikacja lokalnie przy commicie oraz w CI/CD.
