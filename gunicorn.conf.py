import sys
import os

REQUIRED_ENV_VARS = ["ACCESS_CODE", "TURNSTILE_SECRET"]
missing_vars = [var for var in REQUIRED_ENV_VARS if not os.environ.get(var)]

if missing_vars:
  print(f"Missing environment variables: {', '.join(missing_vars)}")
  sys.exit(1)
