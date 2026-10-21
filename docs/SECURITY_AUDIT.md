# Security Audit Runbook — Viral Startup

**Purpose:** Verify that the public Git repository does not expose credentials or Terraform runtime artifacts.

## 1. Inspect tracked files

Run from the repository root in PowerShell:

```powershell
git status --short
git ls-files
git ls-files | Select-String -Pattern 'terraform\.tfvars$|\.tfstate|\.tfplan|\.pem$|\.key$|\.zip$|\.env'
```

Review every result. Some ZIP files may be intentional source artifacts, but deployment bundles should normally be generated locally rather than committed.

## 2. Verify ignore rules

```powershell
git check-ignore -v terraform.tfvars
git check-ignore -v terraform.tfstate
git check-ignore -v terraform.tfstate.backup
git check-ignore -v tfplan
```

An ignored file that was already committed remains tracked until removed from the index. Check with `git ls-files` as well.

## 3. Scan current tracked Terraform files for common secret patterns

```powershell
git grep -n -I -E 'AKIA[0-9A-Z]{16}|aws_secret_access_key|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|password[[:space:]]*=[[:space:]]*"[^"]+"' -- '*.tf' '*.py' '*.js' '*.json'
```

This is a heuristic scan, not proof that a repository is clean. Inspect matches manually; placeholders and legitimate variable references may produce false positives. Also review the full staged diff before every commit:

```powershell
git diff --cached --check
git diff --cached
```

## 4. Scan Git history

A secret deleted from the latest version may still exist in a previous commit. If a real credential was committed:
1. Revoke/rotate it immediately.
2. Identify affected commits and exposure.
3. Remove the secret from repository history if necessary.
4. Coordinate with collaborators before rewriting history.
5. Do not assume history rewriting makes a leaked credential safe; rotation is essential.

## 5. Check frontend configuration

Frontend JavaScript is public. It must not contain database passwords, AWS secret access keys, private API tokens, or other server-side secrets. API URLs and non-secret public identifiers may be visible by design.

```powershell
Get-Content .\viral-startup-site-bundle\s3-static-site\config.js
```

## 6. Verify Terraform state and local files

```powershell
git ls-files | Select-String -Pattern 'tfstate|tfplan|terraform\.tfvars'
git status --short --ignored
```

Do not upload state files to GitHub. State may contain sensitive values even if the application source has no credentials.

## 7. AWS-side checks

- Confirm RDS public accessibility is disabled unless intentionally required and documented.
- Review RDS security-group inbound rules.
- Confirm Lambda security group egress and subnet routes are intentional.
- Review Lambda execution role permissions.
- Confirm S3 bucket public access/origin access settings.
- Review CloudWatch logs for accidental secret output.
- Review AWS billing for NAT Gateway and RDS charges.

## Audit record

Fill this in after running the checks:

- Date:
- Commit reviewed:
- Tracked secret scan result:
- Terraform state/vars check:
- Git history reviewed:
- AWS-side checks:
- Findings:
- Remediation:
- Final status: PASS / NEEDS WORK

**Important:** Do not write actual secret values in this report or paste them into chat.
