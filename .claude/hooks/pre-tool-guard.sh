#!/bin/bash
# DO hook — blocks dangerous Bash commands before they execute

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block bare "terraform destroy" (no -auto-approve) — unconfirmed, outside of /tf-destroy skill
if echo "$CMD" | grep -qP "terraform destroy(?!.*-auto-approve)"; then
  echo '{"decision": "block", "reason": "Destructive command detected. Use /tf-destroy for a safe, confirmed teardown."}'
  exit 0
fi

# Block direct aws s3 destructive commands
if echo "$CMD" | grep -qE "aws s3 rm|aws s3 rb"; then
  echo '{"decision": "block", "reason": "Destructive command detected. Use /tf-destroy or /tf-apply commands for safety."}'
  exit 0
fi
