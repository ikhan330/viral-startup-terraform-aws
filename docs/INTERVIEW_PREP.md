# Viral Startup — Cloud Engineer Interview Notes

Use these notes to explain the design in your own words. Be precise about what is deployed versus what is only a future improvement.

## 1. Walk me through the architecture

“The static frontend is stored in S3 and delivered through CloudFront. Browser API requests go to API Gateway, which invokes a Python Lambda function. Lambda connects to PostgreSQL on RDS. Terraform defines the infrastructure, and GitHub stores the source and change history.”

## 2. Why CloudFront in front of S3?

CloudFront provides a globally distributed cache and HTTPS delivery. It can reduce latency and origin requests. For a private S3 origin, configure an appropriate origin access mechanism and bucket policy rather than making the bucket public.

## 3. Why API Gateway?

It provides an HTTPS API entry point and routes requests to backend integrations such as Lambda. It separates API exposure from backend implementation and can support throttling, authorization, and monitoring when configured.

## 4. Why Lambda?

Lambda runs backend code without managing a persistent server. It scales with request volume within configured limits. The engineer still needs to consider timeouts, memory, concurrency, dependency packaging, logs, and error handling.

## 5. Why put Lambda in a VPC?

Lambda needs VPC networking when it must access private resources such as an RDS database in private subnets. VPC attachment alone does not give Lambda internet access. For outbound internet access from private subnets, routing through a NAT Gateway is a common pattern. NAT is outbound-only and is not an inbound entry point.

## 6. Why NAT Gateway?

A NAT Gateway allows resources in private subnets to initiate outbound IPv4 connections while not accepting unsolicited inbound connections from the internet. It can be used for external API calls or retrieving external resources. It incurs hourly and data-processing charges, so validate the need and cost. A single NAT Gateway is a potential availability bottleneck; multi-AZ designs may use one NAT Gateway per AZ depending on resilience and budget requirements.

## 7. How do you protect RDS?

- Keep RDS private when possible.
- Permit database-port ingress only from the application security group or other explicitly approved sources.
- Use strong credentials and avoid embedding them in source control.
- Use IAM least privilege for the Lambda execution role.
- Enable backups and test restores.
- Encrypt data at rest and in transit as required.
- Monitor logs, metrics, and failed connections.

Do not claim all controls are enabled until you verify the actual Terraform and AWS settings.

## 8. What does Terraform provide?

Terraform is Infrastructure as Code: resources are described declaratively, reviewed as code, and changed through plans. `terraform plan` previews proposed changes; `terraform apply` performs them. State maps configuration to managed resources and must be protected. A lock file records provider selections.

## 9. What does `terraform validate` prove?

It checks whether the configuration is syntactically and internally valid. It does not prove that credentials are authorized, AWS resources can be created, networking works, or the application behaves correctly. Those require plan review and runtime tests.

## 10. How would you troubleshoot an API failure?

1. Confirm the exact request, timestamp, status code, and response.
2. Check API Gateway route/integration and execution logs.
3. Check Lambda invocation metrics, logs, timeout, runtime, and environment configuration.
4. Verify Lambda subnet/security-group attachment and route tables.
5. Test database DNS/connectivity and RDS security-group rules.
6. Identify the root cause from evidence, apply the smallest safe fix, and rerun the same test.
7. Document prevention and the evidence.

## 11. How do you manage costs?

Review RDS instance/storage, NAT Gateway hours and data processing, CloudFront transfer, Lambda/API usage, logs, and other active resources. Use billing alerts/budgets and remove unused development resources carefully. Never destroy a database without confirming data-retention requirements.

## 12. STAR troubleshooting story template

- **Situation:** What failed and what was the impact?
- **Task:** What were you responsible for?
- **Action:** Which commands, logs, routes, security groups, or metrics did you inspect?
- **Result:** What evidence confirmed the root cause and successful fix?
- **Prevention:** What monitoring, test, runbook, or design change prevents recurrence?

Use a real incident from your own work; do not invent a root cause or claim tests you did not perform.
