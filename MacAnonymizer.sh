#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}"
echo '
█▀▄▀█ ▄▀█ █▀▀ ▄▀█ █▄░█ █▀█ █▄░█ █▄█ █▀▄▀█ █ ▀█ █▀▀ █▀█
█░▀░█ █▀█ █▄▄ █▀█ █░▀█ █▄█ █░▀█ ░█░ █░▀░█ █ █▄ ██▄ █▀▄
'
echo -e "${NC}"


change_mac_address() {
    local interface=$1
    NEW_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))
    sudo ip link set "$interface" down
    sudo ip link set "$interface" address "$NEW_MAC"
    sudo ip link set "$interface" up
    echo -e "${GREEN}Changed MAC address of $interface to $NEW_MAC${RESET}"
}

cleanup() {
    echo -e "${RED}Script interrupted. Exiting.${RESET}"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo -e "${CYAN}Available network interfaces:${RESET}"
ip link show | grep "state UP" | awk -F: '{print $2}' | sed 's/ //g' | sed "s/^/${CYAN}- /g"

echo -e -n "${YELLOW}Please enter the name of the network interface you want to use (e.g., wlan0): ${RESET}"
read NETWORK_INTERFACE

if [[ -z "$NETWORK_INTERFACE" ]]; then
    echo -e "${RED}No network interface selected. Exiting.${RESET}"
    exit 1
fi

echo -e -n "${YELLOW}Please enter the interval (in seconds) for changing the MAC address: ${RESET}"
read INTERVAL

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid interval. Please enter a positive integer. Exiting.${RESET}"
    exit 1
fi

echo -e "${BLUE}You selected interface $NETWORK_INTERFACE with an interval of $INTERVAL seconds.${RESET}"
echo -e "${BLUE}Press Ctrl+C to stop the script.${RESET}"

while true; do
    change_mac_address "$NETWORK_INTERFACE"
    sleep "$INTERVAL"
done
