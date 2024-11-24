#!/bin/bash

# Clear the screen and set up functions for cursor handling
clear
hide_cursor() { echo -ne "\033[?25l"; }
show_cursor() { echo -ne "\033[?25h"; }

# Print header
print_header() {
    echo "
#######################################################################################
#                                                                                     #
#                                  Minecraft                                          #
#                                                                                     #
#                           Copyright (C) 2023 - 2024                                 #
#                                                                                     #
#######################################################################################"
}

if ! command -v java &> /dev/null; then
    echo "Java is not installed. Proceeding to select and install JDK."

    jdk_versions=("openjdk-8-jdk" "openjdk-11-jdk" "openjdk-16-jdk" "openjdk-17-jdk" "openjdk-21-jdk")
    selected_jdk=3 # Default to JDK 17

    jdk_options=("OpenJDK 8" "OpenJDK 11" "OpenJDK 16" "OpenJDK 17" "OpenJDK 21")
    while true; do
        clear
        echo "Select the OpenJDK version you want to install:"
        for i in "${!jdk_options[@]}"; do
            if [ $i -eq $selected_jdk ]; then
                echo -e "\033[1m> ${jdk_options[$i]}\033[0m"
            else
                echo "  ${jdk_options[$i]}"
            fi
        done
        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 key
                case "$key" in
                    "[A")
                        ((selected_jdk--))
                        if [ $selected_jdk -lt 0 ]; then
                            selected_jdk=$((${#jdk_options[@]} - 1))
                        fi
                        ;;
                    "[B")
                        ((selected_jdk++))
                        if [ $selected_jdk -ge ${#jdk_options[@]} ]; then
                            selected_jdk=0
                        fi
                        ;;
                esac
                ;;
            "")
                jdk_version=${jdk_versions[$selected_jdk]}
                break
                ;;
        esac
    done


    if ! dpkg -l | grep -q "$jdk_version"; then
        sudo apt-get update
        sudo apt-get install -y "$jdk_version"
    fi
else
    echo "Java is already installed. Skipping JDK selection and installation."
fi


options=(
    "Vanilla"
    "Spigot (using BuildTools)"
    "Paper"
    "Purpur"
)
selected=0

print_menu() {
    clear
    print_header
    echo "Use UP/DOWN arrow keys to navigate and press ENTER to select."
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "\033[1m> ${options[$i]}\033[0m" # Highlight the selected option
        else
            echo "  ${options[$i]}"
        fi
    done
}

# Trap to restore cursor on exit
trap show_cursor EXIT
hide_cursor

# Menu navigation loop
while true; do
    print_menu
    read -rsn1 key
    case "$key" in
        $'\x1b') # Escape sequence
            read -rsn2 -t 0.1 key
            case "$key" in
                "[A") # Arrow up
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                "[B") # Arrow down
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                    ;;
            esac
            ;;
        "") # Enter key
            server_choice=$selected
            break
            ;;
    esac
done

# Prompt for server folder
read -p "Enter a name for your Minecraft server folder: " server_folder
mkdir -p "$server_folder"
cd "$server_folder" || exit

# Prompt for server version
read -p "Enter the server version you want to install (e.g., 1.20.1): " server_version

# Determine the download URL based on menu selection
case $server_choice in
    0)
        server_url="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
        server_name="Vanilla"
        ;;
    1)
        wget -O BuildTools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
        java -jar BuildTools.jar --rev "$server_version"
        server_name="Spigot"
        server_url="spigot-$server_version.jar"
        ;;
    2)
        server_url="https://api.papermc.io/v2/projects/paper/versions/${server_version}/builds/latest/downloads/paper-${server_version}-latest.jar"
        server_name="Paper"
        ;;
    3)
        server_url="https://api.purpurmc.org/v2/purpur/${server_version}/latest/download"
        server_name="Purpur"
        ;;
esac

# Download the server jar
if [[ $server_choice -ne 1 ]]; then
    wget -O server.jar "$server_url"
fi


if ! dpkg -l | grep -q "$jdk_version"; then
    sudo apt-get update
    sudo apt-get install -y "$jdk_version"
fi

# Accept EULA and configure server
read -p "Do you accept the Minecraft EULA? (yes/no): " eula_acceptance
if [[ "$eula_acceptance" =~ ^[Yy][Ee][Ss]?$ ]]; then
    echo "eula=true" > eula.txt
    read -p "Enter RAM to allocate (in GB): " ram_amount
    echo "#!/bin/bash" > start.sh
    echo "java -Xms${ram_amount}G -Xmx${ram_amount}G -jar server.jar nogui" >> start.sh
    chmod +x start.sh
    ./start.sh
else
    echo "You must accept the EULA to proceed. Exiting."
    exit 1
fi

GREEN="\033[0;32m"
YELLOW="\033[0;33m"-e
RED="\033[0;31m"
RESET="\033[0m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
RESET_COLOR="\033[0m"

# Lấy thông tin hệ thống
OS_VERSION=$(lsb_release -ds 2>/dev/null || echo "N/A")
CPU_NAME=$(lscpu | awk -F: '/Model name:/ {print $2}' | sed 's/^ //')
CPU_ARCH=$(uname -m)
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print $2 + $4}')
TOTAL_RAM=$(free -h --si | awk '/^Mem:/ {print $2}')
USED_RAM=$(free -h --si | awk '/^Mem:/ {print $3}')
DISK_SPACE=$(df -h / | awk 'NR==2 {print $2}')
USED_DISK=$(df -h / | awk 'NR==2 {print $3}')
PORTS=$(ss -tunlp | wc -l)
IP_ADDRESS=$(hostname -I | awk '{print $1}')


display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
}

display_version() {
  echo -e "${WHITE}_______________________________________________________________________${RESET_COLOR}"
  echo -e "${CYAN}OS:${RESET} $OS_VERSION"
  echo -e "${CYAN}CPU:${RESET} $CPU_NAME [$CPU_ARCH]"
  echo -e "${CYAN}Used CPU:${RESET} ${CPU_USAGE}%"
  echo -e "${GREEN}RAM:${RESET} $USED_RAM / $TOTAL_RAM"
  echo -e "${YELLOW}Disk:${RESET} $USED_DISK / $DISK_SPACE"
  echo -e "${RED}Ports:${RESET} $PORTS"
  echo -e "${RED}IP:${RESET} $IP_ADDRESS"
  echo -e "${WHITE}_______________________________________________________________________${RESET_COLOR}"
}

clear
display_version
echo  ""
display_gg

