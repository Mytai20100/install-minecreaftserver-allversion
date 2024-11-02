#!/bin/bash

# Clear the screen
clear

# LEAVE CREDITS
echo "
#######################################################################################
#
#                                  mytai
#
#                           Copyright (C) 2021 - 2024
#
#
#######################################################################################"

# Prompt user for server folder name
read -p "Enter a name for your Minecraft server folder: " server_folder
mkdir -p "$server_folder"
cd "$server_folder" || exit

# Prompt user to choose server type
echo "Select the type of Minecraft server to install:"
echo "1) Vanilla"
echo "2) Spigot"
echo "3) Paper"
echo "4) Purpur"
read -p "Enter the number corresponding to the server type (default is Vanilla): " server_choice
server_choice=${server_choice:-1} # Default to Vanilla

# Prompt user for specific server version
read -p "Enter the server version you want to install (e.g., 1.20.1): " server_version

# Determine the download URL based on user selection and version
case $server_choice in
    1) 
        server_url="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar" 
        server_name="Vanilla"
        ;;
    2) 
        server_url="https://download.getbukkit.org/spigot/spigot-${server_version}.jar" 
        server_name="Spigot"
        ;;
    3) 
        server_url="https://api.papermc.io/v2/projects/paper/versions/${server_version}/builds/latest/downloads/paper-${server_version}-latest.jar" 
        server_name="Paper"
        ;;
    4) 
        server_url="https://api.purpurmc.org/v2/purpur/${server_version}/latest/download" 
        server_name="Purpur"
        ;;
    *) 
        echo "Invalid option, defaulting to Vanilla."
        server_url="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
        server_name="Vanilla"
        ;;
esac

echo "Downloading $server_name server (version $server_version) from $server_url..."

# Check if wget is installed, use curl if wget is not found
if command -v wget &> /dev/null; then
    wget clone -O server.jar "$server_url"
else
    echo "wget not found, using curl..."
    if command -v curl &> /dev/null; then
        curl clone -L -o server.jar "$server_url"
        
        # Kiểm tra nếu curl gặp lỗi
        if [ $? -ne 0 ]; then
            echo "Error: Failed to download server file with curl. Please check the URL or your internet connection."
            exit 1
        fi
    else
        echo "Error: Neither wget nor curl is installed. Please install one of them to proceed."
        exit 1
    fi
fi

# Check and install the selected JDK version if necessary
echo "Select the OpenJDK version you want to install:"
echo "1) OpenJDK 8"
echo "2) OpenJDK 11"
echo "3) OpenJDK 16"
echo "4) OpenJDK 17"
echo "5) OpenJDK 21"
read -p "Enter the number corresponding to the JDK version (default is 17): " jdk_choice
jdk_choice=${jdk_choice:-4} # Default to JDK 17

case $jdk_choice in
    1) jdk_version="openjdk-8-jdk" ;;
    2) jdk_version="openjdk-11-jdk" ;;
    3) jdk_version="openjdk-16-jdk" ;;
    4) jdk_version="openjdk-17-jdk" ;;
    5) jdk_version="openjdk-21-jdk" ;;
    *) echo "Invalid option, defaulting to OpenJDK 17."; jdk_version="openjdk-17-jdk" ;;
esac

# Check if the selected JDK is already installed
if ! dpkg -l | grep -q "$jdk_version"; then
    echo "Installing $jdk_version..."
    sudo apt-get update
    sudo apt-get install -y "$jdk_version"
else
    echo "$jdk_version is already installed, skipping installation."
fi

# Ask the user if they accept the Minecraft EULA
read -p "Do you accept the Minecraft EULA? (Type 'yes' or 'y' to accept): " eula_acceptance

# Check if the user accepted the EULA
if [[ "$eula_acceptance" =~ ^[Yy][Ee][Ss]?$ ]]; then
    # Ask the user for the amount of RAM to allocate
    read -p "How much RAM would you like to allocate to the Minecraft server (in GB)? " ram_amount

    # Save Java command with user's response in a start.sh script
    java_command="java -Xms${ram_amount}G -Xmx${ram_amount}G -jar server.jar nogui"
    echo "#!/bin/bash" > start.sh
    echo "$java_command" >> start.sh
    chmod +x start.sh

    # Modify the eula.txt file to set 'true'
    echo "eula=true" > eula.txt

    # Launch the Minecraft server
    echo "Starting $server_name server with ${ram_amount}G RAM..."
    ./start.sh
else
    echo "You must accept the Minecraft EULA to proceed. Aborting."
fi
