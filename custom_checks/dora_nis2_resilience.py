from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories


class DoraRdsBackupAndEncryptionCheck(BaseResourceCheck):
    def __init__(self):
        name = "DORA Art.9/12 & NIS2: Baza RDS musi mieć włączone szyfrowanie (storage_encrypted) oraz retencję backupów >= 7 dni"
        id = "CKV_DORA_001"
        supported_resources = ["aws_db_instance"]
        categories = [CheckCategories.BACKUP_AND_RECOVERY, CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        encrypted = conf.get("storage_encrypted", [False])[0]
        retention = conf.get("backup_retention_period", [0])[0]
        if encrypted is True and isinstance(retention, int) and retention >= 7:
            return CheckResult.PASSED
        return CheckResult.FAILED


class DoraAzureKeyVaultResilienceCheck(BaseResourceCheck):
    def __init__(self):
        name = "DORA Art.9/11 & NIS2: Azure Key Vault musi mieć włączony purge_protection, soft_delete >= 7 dni oraz network_acls default_action = Deny"
        id = "CKV_DORA_002"
        supported_resources = ["azurerm_key_vault"]
        categories = [CheckCategories.BACKUP_AND_RECOVERY, CheckCategories.ENCRYPTION, CheckCategories.NETWORKING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        purge_protection = conf.get("purge_protection_enabled", [False])[0]
        retention = conf.get("soft_delete_retention_days", [0])[0]
        network_acls = conf.get("network_acls", [{}])[0]
        default_action = network_acls.get("default_action", ["Allow"])[0] if isinstance(network_acls, dict) else "Allow"

        if (
            purge_protection is True
            and isinstance(retention, int)
            and retention >= 7
            and default_action == "Deny"
        ):
            return CheckResult.PASSED
        return CheckResult.FAILED


check_rds = DoraRdsBackupAndEncryptionCheck()
check_kv = DoraAzureKeyVaultResilienceCheck()
