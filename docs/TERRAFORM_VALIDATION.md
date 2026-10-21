# Terraform Validation Runbook

Run from the directory containing the root Terraform files.

## 1. Format

```powershell
terraform fmt -check -recursive
```

If formatting fails, apply formatting and inspect the resulting diff:

```powershell
terraform fmt -recursive
git diff
```

## 2. Initialize providers and modules

```powershell
terraform init
```

Initialization downloads provider plugins and configures the working directory. Keep `.terraform.lock.hcl` under version control to record provider selections.

## 3. Validate configuration

```powershell
terraform validate
```

This checks Terraform configuration consistency. It does not prove that AWS permissions, quotas, routes, application behavior, or the live deployment are correct.

## 4. Review a plan

```powershell
terraform plan -out=tfplan
terraform show tfplan
```

Check for unexpected replacements/deletions, public exposure, wrong subnet/security-group references, and cost-impacting resources before applying. Keep `tfplan` local and do not commit it.

## 5. Smoke tests

Use the actual deployed URLs and resource identifiers from your environment; do not copy example values blindly.

- Open the CloudFront frontend URL over HTTPS.
- Call the API health endpoint and confirm the expected success response.
- Read application data through the API.
- Submit a test record and verify it is stored correctly.
- Inspect Lambda logs in CloudWatch for errors.
- Verify database connectivity and access restrictions.
- If Lambda needs outbound internet, verify the private subnet route table and NAT path.

## 6. Record evidence

Save redacted terminal output and screenshots under a suitable `screenshots/` or `docs/evidence/` directory. Record command, date, result, and any failure. Do not report a check as passed until it has actually run successfully.

| Check | Result | Evidence |
|---|---|---|
| `terraform fmt -check -recursive` | Pending | |
| `terraform init` | Pending | |
| `terraform validate` | Pending | |
| `terraform plan` reviewed | Pending | |
| Frontend smoke test | Pending | |
| API smoke test | Pending | |
| Database test | Pending | |
| Security review | Pending | |
