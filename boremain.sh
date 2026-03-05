#!/bin/bash

# Function to display the ASCII banner and menu
show_banner() {
    echo " _                      _          _                "
    echo "| |__   ___  _ __ ___  | |__   ___| |_ __   ___ _ __ "
    echo "| '_ \\ / _ \\| '__/ _ \\ | '_ \\ / _ \\ | '_ \\ / _ \\ '__|"
    echo "| |_) | (_) | | |  __/ | | | |  __/ | |_) |  __/ |   "
    echo "|_.__/ \\___/|_|  \\___| |_| |_|\\___|_| .__/ \\___|_|   "
    echo "                                    |_|              "
    echo ""
    echo "[!] Select a service you want to tunnel using BORE"
    echo "1 - SSH"
    echo "2 - HTTP/HTTPS"
    echo "3 - Custom port (other)"
    echo "------------------"
    echo "11 - Exit"
}

while true; do
    show_banner
    read -p "helper@bore.pub \$~ " choice

    case $choice in
        1)
            echo "[*] Starting SSH tunnel..."
            bash <(curl -s https://raw.githubusercontent.com/layaneyqueen/BORE-SSH-HELPER/refs/heads/main/boressh.sh)
            ;;
        2)
            read -p "HTTP (80), or HTTPS (443)? " http_choice
            if [[ "$http_choice" == "80" ]]; then
                echo "[*] Starting HTTP (port 80) tunnel..."
                bash <(curl -s https://raw.githubusercontent.com/layaneyqueen/BORE-SSH-HELPER/refs/heads/main/borehttp.sh)
            elif [[ "$http_choice" == "443" ]]; then
                echo "[*] Starting HTTPS (port 443) tunnel..."
                bash <(curl -s https://raw.githubusercontent.com/layaneyqueen/BORE-SSH-HELPER/refs/heads/main/borehttps.sh)
            else
                echo "[!] Invalid input. Please enter 80 or 443."
            fi
            ;;
        3)
            read -p "Enter the custom local port you want to tunnel: " custom_port
            echo "[*] Starting custom port tunnel..."
            bash <(curl -s https://raw.githubusercontent.com/layaneyqueen/BORE-SSH-HELPER/refs/heads/main/borecustom.sh) "$custom_port"
            ;;
        11)
            echo "[*] Exiting bore-helper."
            exit 0
            ;;
        *)
            echo "[!] Invalid choice. Try again."
            ;;
    esac

    echo ""
    read -p "Press ENTER to return to main menu..."
done
