#!/bin/bash
# shellcheck shell=bash

# _______ _______ _____ __   _  ______ _______
#     |    |_____|   |   | \  | |_____/ |______
#     |    |     | __|__ |  \_| |    \_ ______|
#


# Script to generate a Plex authentication token
# Prompts the user for token description, username, password, and 2FA code
# Uses the provided information to authenticate with Plex and retrieve a token
# Requires 'curl' and 'jq' to be installed

# Check if 'jq' is installed
if ! command -v jq > /dev/null; then
    echo "Error: 'jq' is not installed. Please install 'jq' to continue."
    exit 1
fi

# Check if 'curl' is installed
if ! command -v curl > /dev/null; then
    echo "Error: 'curl' is not installed. Please install 'curl' to continue."
    exit 1
fi

# Prompt the user for input
read -r -p "Enter Plex authentication token description: " plex_product
read -r -p "Enter username: " plex_username
read -r -s -p "Enter password: " plex_password
echo
read -r -p "Enter 2FA code: " plex_2facode

# Perform the authentication request to Plex and retrieve the Plex authentication token
plex_token=$(curl -fsSL -u "${plex_username}:${plex_password}${plex_2facode}" 'https://plex.tv/users/sign_in.json' -X POST \
    -H "X-Plex-Client-Identifier: $(cat /proc/sys/kernel/random/uuid)" \
    -H "X-Plex-Product: ${plex_product}" \
    -H "X-Plex-Version: $(date -u +'%Y%m%d%H%M%S')" \
    -H "X-Plex-Provides: controller" \
    -H "X-Plex-Device: $(uname -s) $(uname -r)" \
    | jq -re '.[].authentication_token')

# Output the retrieved token
echo "Your Plex authentication token: ${plex_token}"
