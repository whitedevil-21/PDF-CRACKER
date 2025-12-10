#!/bin/bash

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- BANNER ---
clear
echo -e "${BLUE}####################################################${NC}"
echo -e "${BLUE}#           PDF CRACKER - BASH SCRIPT              #${NC}"
echo -e "${BLUE}#           OWNER BY AMIT DEVI(WHITEDEVIL-21)      #${NC}"
echo -e "${BLUE}#           ${YELLOW}Offline & Colored Output${BLUE}      #${NC}"
echo -e "${BLUE}####################################################${NC}"
echo ""

# --- DEPENDENCY CHECK ---
if ! command -v qpdf &> /dev/null; then
    echo -e "${RED}[!] Error: 'qpdf' is not installed.${NC}"
    echo -e "${YELLOW}[*] Please install it first:${NC}"
    echo -e "    Termux:  pkg install qpdf"
    echo -e "    Linux:   sudo apt install qpdf"
    exit 1
fi

# --- INPUT HANDLING ---
PDF_FILE=$1
WORDLIST=$2

if [ -z "$PDF_FILE" ]; then
    echo -e -n "${CYAN}[?] Enter path to PDF file: ${NC}"
    read PDF_FILE
fi

# Fix: Only remove surrounding quotes if user dragged/dropped, 
# preserving quotes inside the actual filename.
PDF_FILE=$(echo "$PDF_FILE" | sed -e "s/^'//" -e "s/'$//")

if [ ! -f "$PDF_FILE" ]; then
    echo -e "${RED}[!] Error: PDF file not found at: $PDF_FILE${NC}"
    exit 1
fi

if [ -z "$WORDLIST" ]; then
    echo -e -n "${CYAN}[?] Enter path to Wordlist: ${NC}"
    read WORDLIST
fi

# Fix: Same quote handling for wordlist
WORDLIST=$(echo "$WORDLIST" | sed -e "s/^'//" -e "s/'$//")

if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}[!] Error: Wordlist file not found at: $WORDLIST${NC}"
    exit 1
fi

# --- ATTACK START ---
echo -e "\n${YELLOW}[*] Starting Attack on: ${NC}$PDF_FILE"
echo -e "${YELLOW}[*] Using Wordlist: ${NC}$WORDLIST"
echo -e "${BLUE}[*] Press Ctrl+C to stop${NC}\n"

COUNT=0
TOTAL_LINES=$(wc -l < "$WORDLIST")

if [ "$TOTAL_LINES" -eq 0 ]; then
    echo -e "${RED}[!] Error: The wordlist is empty.${NC}"
    exit 1
fi

# --- THE LOOP ---
# IFS= prevents read from trimming leading/trailing whitespace from passwords
while IFS= read -r password || [ -n "$password" ]; do
    ((COUNT++))
    
    # FIX: Remove Windows Carriage Return (\r) if present
    password=${password//$'\r'/}

    # FIX: \033[K clears the rest of the line to prevent visual glitches
    echo -ne "${YELLOW}\r[*] Trying [$COUNT / $TOTAL_LINES]: ${NC}$password\033[K"
    
    # Try to decrypt using qpdf
    # Use the password to verify encryption status
    qpdf --password="$password" --decrypt "$PDF_FILE" /dev/null 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "\n"
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}[+] PASSWORD FOUND: ${NC}$password"
        echo -e "${GREEN}========================================${NC}"
        exit 0
    fi

done < "$WORDLIST"

# --- FAILURE ---
echo -e "\n"
echo -e "${RED}[-] Password not found in the list.${NC}"
exit 1

