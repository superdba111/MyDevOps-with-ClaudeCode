---
name: tf-destroy
description: Safely destroy all AWS infrastructure provisioned by Terraform. Runs a destroy plan first, then requires explicit user confirmation before proceeding.
allowed-tools: Bash, Read
disable-model-invocation: true
---

## Step 1 — Show destroy plan

Run `cd terraform && terraform plan -destroy -no-color` and summarize what will be deleted:
- [ ] List every resource that will be destroyed (S3 bucket, CloudFront distribution, IAM roles, OIDC provider, DynamoDB table, etc.)
- [ ] Warn if the S3 state bucket itself is included — destroying it makes state recovery impossible
- [ ] State the total count: "X resources will be destroyed"

## Step 2 — Confirm with the user

Stop and ask the user:

> **This will permanently delete all AWS infrastructure listed above.**
> Type `yes, destroy everything` to confirm, or anything else to cancel.

Do NOT proceed until the user provides that exact confirmation phrase.

## Step 3 — Run destroy

Only after confirmation, run:

```bash
cd terraform && terraform destroy -auto-approve -no-color
```

- [ ] Stream output as it runs
- [ ] On success: confirm all resources were destroyed and log to `.claude/deploy.log` with timestamp
- [ ] On failure: show the error, do NOT retry automatically, wait for instructions

## Step 4 — Post-destroy summary

Report:
- What was destroyed
- Any resources that failed to destroy (manual cleanup needed)
- Reminder that the Terraform state backend (S3 + DynamoDB) may still exist if it was excluded — note if manual cleanup is needed
