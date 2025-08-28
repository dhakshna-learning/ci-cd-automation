#!/bin/bash
# created by DhakshnamoorthyM to generate a short live token
# -------------------------------
# 🔧 CONFIGURATION
# -------------------------------
APP_ID="1853338"
INSTALLATION_ID="83071637"
PRIVATE_KEY_PATH=$1

# -------------------------------
# 🕒 Generate time-based claims
# -------------------------------
NOW=$(date +%s)
IAT=$NOW
EXP=$(($NOW + 600)) # 10 minutes from now

# -------------------------------
# 🛠️ Create JWT Header & Payload
# -------------------------------
HEADER='{"alg":"RS256","typ":"JWT"}'
PAYLOAD="{\"iat\":${IAT},\"exp\":${EXP},\"iss\":${APP_ID}}"

BASE64_HEADER=$(echo -n "${HEADER}" | openssl base64 -e -A | tr -d '=' | tr '/+' '_-')
BASE64_PAYLOAD=$(echo -n "${PAYLOAD}" | openssl base64 -e -A | tr -d '=' | tr '/+' '_-')
HEADER_PAYLOAD="${BASE64_HEADER}.${BASE64_PAYLOAD}"

# -------------------------------
# 🔏 Sign the JWT
# -------------------------------
JWT_SIGNATURE=$(echo -n "${HEADER_PAYLOAD}" | openssl dgst -sha256 -sign "$PRIVATE_KEY_PATH" | openssl base64 -A | tr -d '=' | tr '/+' '_-')
JWT="${HEADER_PAYLOAD}.${JWT_SIGNATURE}"

# -------------------------------
# 📡 Request GitHub Token
# -------------------------------
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer ${JWT}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/${INSTALLATION_ID}/access_tokens)

# -------------------------------
# 📤 Output the Token
# -------------------------------
TMP_TOKEN=$(echo "$RESPONSE" | grep '"token":' | cut -d '"' -f 4)
echo "TMP_TOKEN=$TMP_TOKEN" >> "$GITHUB_ENV"

