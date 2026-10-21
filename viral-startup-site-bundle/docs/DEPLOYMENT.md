# Deployment checklist (existing VPC / RDS)

## 1. Lambda function

- Runtime: Python 3.12
- Handler: `handler.lambda_handler`
- Architecture: x86_64
- Memory: 256 MB to start; timeout: 15–30 seconds
- Upload `lambda-deployment.zip` from this folder after building it.
- Environment variables:
  - `DB_HOST`: RDS endpoint hostname only (no `https://`)
  - `DB_NAME`: database name, e.g. `viralstartup`
  - `DB_USER`: database username
  - `DB_PASSWORD`: password
  - `DB_PORT`: `5432`
  - `ALLOWED_ORIGIN`: exact CloudFront origin, e.g. `https://d123example.cloudfront.net`

## 2. VPC / Security Groups

- Attach Lambda to the private application subnets shown in your diagram.
- Lambda SG egress: TCP 5432 to the RDS SG. Lambda also needs to reach AWS logging services; Lambda service manages logs, but private networking policies/endpoints must not block required AWS APIs.
- RDS SG ingress: TCP 5432 **from Lambda's security group only**.
- RDS should be `Publicly accessible: No`.
- The DB subnet group must contain private database subnets in at least two AZs.
- A Lambda attached to a private subnet does not need NAT merely to connect to RDS. Do not add NAT just for the database connection.
- Verify subnet CIDRs do not overlap and match the actual VPC. The diagram is a plan; always use IDs/CIDRs from the AWS console.

## 3. API Gateway HTTP API

Create an HTTP API and add a Lambda proxy integration to this function. Payload format version 2.0.
Routes:
- `GET /health`
- `GET /ideas`
- `POST /ideas`

Enable CORS:
- Allowed origin: your exact CloudFront origin
- Allowed methods: `GET`, `POST`, `OPTIONS`
- Allowed header: `content-type`

Deploy to `$default` stage with auto-deploy enabled. The invoke URL should look like `https://API_ID.execute-api.ap-south-1.amazonaws.com`.

## 4. S3 + CloudFront

- Upload the *contents* of `s3-static-site/` into the bucket root: `index.html`, `styles.css`, `app.js`, `config.js`.
- Keep S3 Block Public Access enabled.
- Use a CloudFront Origin Access Control (OAC) and bucket policy allowing `s3:GetObject` only to the CloudFront distribution.
- Update `config.js` to:
  `window.APP_CONFIG = { API_BASE: "https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com" };`
  Do not add `/ideas` to the base URL.
- Set CloudFront default root object to `index.html`, viewer policy redirect HTTP to HTTPS.
- Invalidate `/*` after changes.

## 5. Test

1. Open `https://YOUR_CLOUDFRONT_DOMAIN/`.
2. Check status label says `Live API connected`.
3. Submit a test idea and confirm it appears on the board after submission.
4. Test `GET /health`, `GET /ideas`, and `POST /ideas`.
5. If 500: inspect `/aws/lambda/YOUR_FUNCTION_NAME` in CloudWatch Logs. Check Lambda/RDS SG and DB environment values.
6. If browser CORS error: ensure API Gateway CORS and Lambda `ALLOWED_ORIGIN` both match the exact CloudFront origin.

## Production TODOs

Authentication/authorization if needed, API throttling, WAF/bot controls, content moderation, anti-spam, Secrets Manager and rotation, alarms, log retention, backups, privacy notice, data deletion request process, and cost alarms.
