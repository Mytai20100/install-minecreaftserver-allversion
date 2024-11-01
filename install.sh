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

# Prompt user to choose server type
echo "Select the type of Minecraft server to install:"
echo "1) Vanilla"
echo "2) Spigot"
echo "3) Paper"
echo "4) Purpur"
read -p "Enter the number corresponding to the server type (default is Vanilla): " server_choice
server_choice=${server_choice:-1} # Default to Vanilla

# Determine the download URL based on user selection
case $server_choice in
    1) 
        server_url="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar" 
        server_name="Vanilla"
        ;;
    2) 
        server_url="https://download.getbukkit.org/spigot/spigot-1.20.1.jar" 
        server_name="Spigot"
        ;;
    3) 
        server_url="https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/199/downloads/paper-1.20.1-199.jar" 
        server_name="Paper"
        ;;
    4) 
        server_url="https://api.purpurmc.org/v2/purpur/1.20.1/latest/download" 
        server_name="Purpur"
        ;;
    *) 
        echo "Invalid option, defaulting to Vanilla."
        server_url="https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
        server_name="Vanilla"
        ;;
esac

echo "Downloading $server_name server from $server_url..."
wget -O server.jar $server_url

# Ask the user to choose a JDK version
echo "Select the OpenJDK version you want to install:"
echo "1) OpenJDK 8"
echo "2) OpenJDK 11"
echo "3) OpenJDK 16"
echo "4) OpenJDK 17"
echo "5) OpenJDK 21"
read -p "Enter the number corresponding to the JDK version (default is 17): " jdk_choice
jdk_choice=${jdk_choice:-4} # Default to JDK 17

# Determine the JDK package name based on user selection
case $jdk_choice in
    1) jdk_version="openjdk-8-jdk" ;;
    2) jdk_version="openjdk-11-jdk" ;;
    3) jdk_version="openjdk-16-jdk" ;;
    4) jdk_version="openjdk-17-jdk" ;;
    5) jdk_version="openjdk-21-jdk" ;;
    *) echo "Invalid option, defaulting to OpenJDK 17."; jdk_version="openjdk-17-jdk" ;;
esac

# Install the selected JDK version
echo "Installing $jdk_version..."
sudo apt-get update
sudo apt-get install -y $jdk_version

# Ask the user if they accept the Minecraft EULA
read -p "Do you accept the Minecraft EULA? (Type 'yes' or 'y' to accept): " eula_acceptance

# Check if the user accepted the EULA
if [[ "$eula_acceptance" =~ ^[Yy][Ee][Ss]?$ ]]; then
    # Ask the user for the amount of RAM to allocate
    read -p "How much RAM would you like to allocate to the Minecraft server (in GB)? " ram_amount

    # Modify the Java command with the user's response
    java_command="java -Xms${ram_amount}G -Xmx${ram_amount}G -jar server.jar nogui"

    # Modify the eula.txt file to set 'true'
    echo "eula=true" > eula.txt

    # Launch the Minecraft server
    echo "Starting $server_name server with ${ram_amount}G RAM..."
    $java_command
else
    echo "You must accept the Minecraft EULA to proceed. Aborting."
fi
