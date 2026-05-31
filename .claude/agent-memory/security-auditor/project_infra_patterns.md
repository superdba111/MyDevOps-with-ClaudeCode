---
name: project-infra-patterns
description: Security-relevant infrastructure patterns observed in this project's Terraform code (S3+CloudFront static site)
metadata:
  type: project
---

Static portfolio site on S3 + CloudFront, provisioned with Terraform. Key security-relevant observations from audits conducted 2026-05-31 (no changes between audit runs; all issues below remain open).

**Why:** Baseline audit to establish known issues for future delta audits.
**How to apply:** On subsequent audits, focus on whether these issues have been remediated and flag any regressions.

## What is correctly configured
- S3 public access block: all four flags enabled (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets)
- CloudFront uses OAC (not legacy OAI) — `aws_cloudfront_origin_access_control` with sigv4 signing
- S3 bucket policy scopes CloudFront access to specific distribution ARN via `AWS:SourceArn` condition
- CloudFront `viewer_protocol_policy = "redirect-to-https"`
- S3 versioning enabled
- No hardcoded credentials or secrets in .tf source files
- IAM policy for S3 bucket uses narrowly scoped action (s3:GetObject only, no wildcards)

## Known issues found (unfixed as of 2026-05-31)

### CRITICAL
- `terraform.tfstate` is committed to the repo (local state, not remote). It contains AWS account ID 488839855180, CloudFront distribution ID, S3 ARN, and OAC ID in plaintext. Remote backend block in backend.tf is commented out.

### HIGH
- CloudFront `viewer_certificate` uses `cloudfront_default_certificate = true` with TLSv1 minimum protocol (from tfstate). No ACM certificate configured; no `minimum_protocol_version` override to TLSv1.2_2021.
- No CloudFront `response_headers_policy_id` set — missing security headers (CSP, X-Frame-Options, X-Content-Type-Options, HSTS, Referrer-Policy).
- No CloudFront access logging configured (`logging_config` is empty in tfstate).
- No S3 server-side encryption resource in Terraform source — encryption exists in live state (AES256 applied by AWS default) but is not enforced in code.

### MEDIUM
- No S3 access logging configured (`logging` is empty in tfstate, no `aws_s3_bucket_logging` resource).
- No AWS WAF WebACL attached to CloudFront (`web_acl_id` is empty in tfstate).
- `custom_error_response` returns HTTP 200 for 404 errors — soft 404s can obscure scraping/enumeration attempts.
- `domain_name` variable has no `validation` block — unconstrained string input.
- Remote backend is fully commented out in backend.tf; tfstate is local and committed.

### LOW
- `http_version` in CloudFront defaults to http2; http3 (QUIC) not enabled.
- No `aws_s3_bucket_lifecycle_configuration` for old versions (versioning is on, but old versions accumulate indefinitely).
- Provider version pinned to `~> 5.0` (minor-version flexible); consider pinning to `~> 5.100` for tighter reproducibility.
