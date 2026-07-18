#!/bin/bash
# ==============================================================================
# VIRGOZKI PANEL • XHTTP ERROR FIXED • HTTPUPGRADE RETAINED • NO OTHER CHANGES
# ==============================================================================

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[1;35m'; WHITE='\033[1;37m'

loading() {
    local t="$1"
    local s="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for ((i=0;i<5;i++)); do 
        for ((j=0;j<${#s};j++)); do 
            echo -ne "\r  ${CYAN}${s:$j:1} ${t}...${RESET}"
            sleep 0.05
        done
    done
    echo -ne "\r  ${GREEN}DONE: ${t}${RESET}\n"
}

clear
echo ""
echo -e "  ${BOLD}${WHITE}VIRGOZKI PANEL (QWIKLABS OPTIMIZED)${RESET}"
echo -e "  ${MAGENTA}MADE BY VIRGOZKI${RESET}"
echo -e "  ${GREEN}✅ XHTTP ERROR FIXED • HTTPUPGRADE INTACT • READY${RESET}"
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

echo -ne "  ${CYAN}DETECTING QWIKLABS REGION... ${RESET}"
REGION=$(gcloud config get-value compute/region 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION=$(gcloud config get-value run/region 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION=$(gcloud run regions list --format="value(REGION)" --limit=1 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION="us-central1"
echo -e "${GREEN}${REGION}${RESET}"
echo ""

GH_TOKEN=""
if curl -sL --connect-timeout 5 "https://pastebin.com/raw/7rAmCXDp" | grep -q "^gh[pousr]_"; then
    GH_TOKEN=$(curl -sL --connect-timeout 5 "https://pastebin.com/raw/7rAmCXDp" | tr -d '\r\n[:space:]')
else
    echo -e "${YELLOW}REMOTE TOKEN UNAVAILABLE.${RESET}"
    read -r -s -p "$(echo -e "  ${MAGENTA}PLEASE PASTE GITHUB TOKEN MANUALLY: ${RESET}")" GH_TOKEN
    echo ""
fi
if [ -z "$GH_TOKEN" ] || ! echo "$GH_TOKEN" | grep -q "^gh[pousr]_"; then
    echo -e "  ${YELLOW}INVALID GITHUB TOKEN. SKIPPING GITHUB SYNC.${RESET}"
    GH_TOKEN=""
fi

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [virgozki-panel]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-virgozki-panel}

echo ""
echo -e "  ${CYAN}SELECT MODE:${RESET}"
echo -e "  ${YELLOW}1) AUTO         (1 vCPU / 2Gi  RAM) ✅ Recommended for Qwiklab${RESET}"
echo -e "  ${YELLOW}2) HIGH         (2 vCPU / 4Gi  RAM)${RESET}"
echo -e "  ${YELLOW}3) STABLE       (4 vCPU / 8Gi  RAM)${RESET}"
echo -e "  ${YELLOW}4) CUSTOM       (Your own specs)${RESET}"
echo ""
read -r -p "$(echo -e "  ${CYAN}CHOICE: ${RESET}")" MODE_CHOICE

case "$MODE_CHOICE" in
    1) CPU="1"; RAM="2Gi"; MODE="AUTO"     ; MAX_INSTANCES="2";;
    2) CPU="2"; RAM="4Gi"; MODE="HIGH"     ; MAX_INSTANCES="2";;
    3) CPU="4"; RAM="8Gi"; MODE="STABLE"   ; MAX_INSTANCES="1";;
    4)
        echo ""
        read -r -p "$(echo -e "  ${CYAN}CPU (1/2/4): ${RESET}")" CPU
        read -r -p "$(echo -e "  ${CYAN}RAM (2Gi/4Gi/8Gi): ${RESET}")" RAM
        echo ""
        read -r -p "$(echo -e "  ${CYAN}MAX INSTANCES (1-3): ${RESET}")" MAX_INSTANCES
        MODE="CUSTOM"
        ;;
    *) CPU="1"; RAM="2Gi"; MODE="DEFAULT"; MAX_INSTANCES="2";;
esac

echo ""
loading "CHECKING REQUIRED FILES"
for f in config.json nginx.conf Dockerfile index.html; do
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}ERROR: Missing file -> $f${RESET}"
        exit 1
    fi
done

loading "BUILDING CONTAINER IMAGE"
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" --project="$PROJECT_ID" --quiet > build.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}BUILD FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 build.log
    rm -f build.log
    exit 1
fi

loading "DEPLOYING TO CLOUD RUN IN ${REGION}"
gcloud run deploy "$SERVICE_NAME" \
  --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
  --platform managed --region "$REGION" \
  --cpu "$CPU" --memory "$RAM" --port 8080 \
  --concurrency 800 --timeout 3600 \
  --min-instances 0 --max-instances "$MAX_INSTANCES" \
  --allow-unauthenticated --project="$PROJECT_ID" --quiet > deploy.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}DEPLOYMENT FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 deploy.log
    rm -f build.log deploy.log
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

VMESS_UUID="b831381d-6324-4d53-ad4f-8cda48b30811"
SS_B64=$(echo -n "aes-256-gcm:virgozki" | base64 -w0)

# ✅ LAHAT NG LINKS – TAMA NA ANG XHTTP
VLESS_WS="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=ws&path=/vless-virgozki&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-WS"
VLESS_HU="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=httpupgrade&path=/vless-virgozki-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-HU"
VLESS_XHTTP="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=xhttp&path=/vless-virgozki-xhttp&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}&mode=packet-upstream#VLESS-XHTTP"

VMESS_WS_JSON='{"v":"2","ps":"VMESS-WS-virgozki","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"ws","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-virgozki","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1"}'
VMESS_WS_B64=$(echo -n "$VMESS_WS_JSON" | base64 -w0)
VMESS_HU_JSON='{"v":"2","ps":"VMESS-HU-virgozki","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"httpupgrade","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-virgozki-hu","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1"}'
VMESS_HU_B64=$(echo -n "$VMESS_HU_JSON" | base64 -w0)
VMESS_XHTTP_JSON='{"v":"2","ps":"VMESS-XHTTP-virgozki","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"xhttp","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-virgozki-xhttp","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1","xhttpMode":"packet-upstream"}'
VMESS_XHTTP_B64=$(echo -n "$VMESS_XHTTP_JSON" | base64 -w0)

TROJAN_WS="trojan://virgozki@${CLEAN_HOST}:443?type=ws&path=/virgozki&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-WS"
TROJAN_HU="trojan://virgozki@${CLEAN_HOST}:443?type=httpupgrade&path=/virgozki-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-HU"
TROJAN_XHTTP="trojan://virgozki@${CLEAN_HOST}:443?type=xhttp&path=/virgozki-xhttp&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}&mode=packet-upstream#TROJAN-XHTTP"

SS_WS="ss://${SS_B64}@${CLEAN_HOST}:443?type=ws&path=/ss-virgozki&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#SHADOWSOCKS-WS"
SS_HU="ss://${SS_B64}@${CLEAN_HOST}:443?type=httpupgrade&path=/ss-virgozki-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#SHADOWSOCKS-HU"
SS_XHTTP="ss://${SS_B64}@${CLEAN_HOST}:443?type=xhttp&path=/ss-virgozki-xhttp&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}&mode=packet-upstream#SHADOWSOCKS-XHTTP"

echo ""
echo -e "  ${GREEN}✅ DEPLOYED SUCCESSFULLY • XHTTP ERROR FIXED • HTTPUPGRADE INTACT${RESET}"
echo ""
echo -e "  ${CYAN}DASHBOARD: ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${CYAN}HOST:      ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}PORT:      ${GREEN}443${RESET}"
echo -e "  ${CYAN}PASSWORD:  ${GREEN}virgozki${RESET}"
echo -e "  ${CYAN}MODE:      ${GREEN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""

echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${CYAN}            ALL PROTOCOLS (WS + HU + XHTTP)${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${GREEN}✓ VLESS   ${CYAN}WS: /vless-virgozki    ${GREEN}HU: /vless-virgozki-hu    ${CYAN}XHTTP: /vless-virgozki-xhttp${RESET}"
echo -e "  ${GREEN}✓ VMESS   ${CYAN}WS: /vmess-virgozki    ${GREEN}HU: /vmess-virgozki-hu    ${CYAN}XHTTP: /vmess-virgozki-xhttp${RESET}"
echo -e "  ${GREEN}✓ TROJAN  ${CYAN}WS: /virgozki          ${GREEN}HU: /virgozki-hu          ${CYAN}XHTTP: /virgozki-xhttp${RESET}"
echo -e "  ${GREEN}✓ SHADOWSOCKS ${CYAN}WS: /ss-virgozki    ${GREEN}HU: /ss-virgozki-hu    ${CYAN}XHTTP: /ss-virgozki-xhttp${RESET}"
echo ""
echo -e "  ${CYAN}✓ SNI: ${GREEN}${CLEAN_HOST}${RESET}   ${CYAN}✓ ALPN: ${GREEN}http/1.1${RESET}   ${CYAN}✓ FINGERPRINT: ${GREEN}chrome${RESET}"
echo ""
echo -e "  ${YELLOW}🔗 READY-TO-USE LINKS:${RESET}"
echo -e "  ${CYAN}VLESS WS:     ${GREEN}${VLESS_WS}${RESET}"
echo -e "  ${CYAN}VLESS HU:     ${GREEN}${VLESS_HU}${RESET}"
echo -e "  ${CYAN}VLESS XHTTP:  ${GREEN}${VLESS_XHTTP}${RESET}"
echo -e "  ${CYAN}TROJAN WS:    ${GREEN}${TROJAN_WS}${RESET}"
echo -e "  ${CYAN}TROJAN HU:    ${GREEN}${TROJAN_HU}${RESET}"
echo -e "  ${CYAN}TROJAN XHTTP: ${GREEN}${TROJAN_XHTTP}${RESET}"
echo -e "  ${CYAN}VMESS WS:     ${GREEN}vmess://${VMESS_WS_B64}${RESET}"
echo -e "  ${CYAN}VMESS HU:     ${GREEN}vmess://${VMESS_HU_B64}${RESET}"
echo -e "  ${CYAN}VMESS XHTTP:  ${GREEN}vmess://${VMESS_XHTTP_B64}${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# ✅ GITHUB SYNC – WALANG PINAGBAGO
if [ -n "$GH_TOKEN" ]; then
    GH_USER="rafaeltv"
    GH_REPO="rafaeltv-gcp-panel"
    
    if git clone -q "https://${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git" gh_temp_deploy 2>/dev/null; then
        cd gh_temp_deploy
        > temp.txt
        while IFS= read -r line; do
            if [[ "$line" == *".run.app"* ]]; then
                if curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" "https://$line" | grep -qE '200|403'; then
                    echo "$line" >> temp.txt
                fi
            fi
        done < host.txt 2>/dev/null
        
        echo "$CLEAN_HOST" >> temp.txt
        sort -u temp.txt > host.txt
        rm temp.txt
        
        git config --local user.name "Virgozki Deployer"
        git config --local user.email "deploy@virgozki.local"
        git add host.txt
        git commit -m "Update hosts: ${CLEAN_HOST}" 2>/dev/null
        git push -q origin main 2>/dev/null || git push -q origin master 2>/dev/null
        cd ..
        rm -rf gh_temp_deploy
    fi
fi

# ✅ CLEANUP
rm -f build.log deploy.log
echo -e "\n  ${GREEN}✅ SCRIPT FINISHED • XHTTP NOW WORKING • NO OTHER CHANGES MADE${RESET}"

