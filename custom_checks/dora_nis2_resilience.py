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


check = DoraRdsBackupAndEncryptionCheck()
