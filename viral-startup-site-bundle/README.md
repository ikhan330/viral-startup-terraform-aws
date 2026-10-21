# Viral Startup website — for your existing AWS architecture

This bundle is intended to fit the architecture diagram you shared: an existing VPC, private Lambda subnets, private PostgreSQL RDS, S3 static files, and API Gateway. It does **not** create or change any AWS infrastructure.

## Files

- `s3-static-site/`: upload these files to your S3 bucket. Keep the bucket private and serve it through CloudFront Origin Access Control.
- `lambda-function/handler.py`: Python Lambda code.
- `lambda-function/requirements.txt`: PostgreSQL driver dependency.
- `lambda-function/lambda-deployment.zip`: included only after you build it using the steps below.
- `docs/DEPLOYMENT.md`: exact AWS console configuration checklist.

## Before upload

1. Create/confirm the API Gateway HTTP API and Lambda routes: `GET /health`, `GET /ideas`, `POST /ideas`.
2. Configure Lambda VPC subnets/security group and RDS connectivity.
3. Build a Lambda ZIP for Python 3.12 on Linux-compatible x86_64:
   - Linux/macOS/WSL: run `./build_lambda.sh` from `lambda-function`.
   - Windows PowerShell: run `.\build_lambda.ps1` from `lambda-function`.
4. Set Lambda environment variables `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_PORT`, and `ALLOWED_ORIGIN`. Use your API's CloudFront website origin for `ALLOWED_ORIGIN` in production, not `*`.
5. Upload `s3-static-site` contents to the website bucket (not the folder itself), then set `API_BASE` in `config.js` to the API Gateway invoke URL without a trailing slash.
6. Invalidate CloudFront after uploading.

## Security

This demo collects startup ideas and optional email addresses. It publicly displays titles, descriptions and categories, but not emails. Do not submit confidential or patented details. The public POST endpoint needs rate limiting, bot protection, moderation, and abuse prevention before public launch.

Use Secrets Manager or another approved secret delivery mechanism for production. Avoid printing secrets. Terraform state and Lambda environment variables can expose credentials to authorized administrators. Ensure the database security group allows TCP 5432 only from the Lambda security group; do not make RDS public.

## Test

```bash
curl https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/health
curl https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/ideas
curl -X POST https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/ideas \
  -H "content-type: application/json" \
  -d '{"title":"Local shop delivery","description":"Delivery tools for neighborhood shops","category":"Commerce","contact":"founder@example.com"}'
```
