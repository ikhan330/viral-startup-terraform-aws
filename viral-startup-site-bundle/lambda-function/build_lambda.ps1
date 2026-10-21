$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Package = Join-Path $Here "package"
New-Item -ItemType Directory -Force $Package | Out-Null
Get-ChildItem -Force $Package | Remove-Item -Recurse -Force
python -m pip install --platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --python-version 3.12 --abi cp312 -r (Join-Path $Here "requirements.txt") -t $Package
Copy-Item (Join-Path $Here "handler.py") $Package
$Zip = Join-Path $Here "lambda-deployment.zip"
if (Test-Path $Zip) { Remove-Item $Zip -Force }
Compress-Archive -Path (Join-Path $Package "*") -DestinationPath $Zip -Force
Write-Host "Created $Zip"
