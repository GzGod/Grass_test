#!/bin/bash

# Function for turning on/restarting Grass (Selection 1)
turn_on_grass() {
    # Prompt the user for Grass access and refresh tokens
    read -p "Grass Access Token: " grass_access
    read -p "Grass Refresh Token: " grass_refresh

    # Update secrets.json with Grass tokens
    jq --arg access "$grass_access" --arg refresh "$grass_refresh" '. + {grass_access: $access, grass_refresh: $refresh}' secrets.json > temp.json && mv temp.json secrets.json

    # Read tokens from secrets.json
    grass_access=$(jq -r '.grass_access' secrets.json)
    grass_refresh=$(jq -r '.grass_refresh' secrets.json)

    # Configure PINGPONG with Grass tokens
    ./PINGPONG config set --grass.access="$grass_access" --grass.refresh="$grass_refresh"

    # Restart Grass dependency
    ./PINGPONG stop --depins=grass
    ./PINGPONG start --depins=grass

    echo "Grass has been configured and restarted."
}

# Main menu function
show_menu() {
    echo "Please select an option:"
    echo "1) Turn on (restart) Grass"
    echo "2) Exit"
    read -p "Enter your choice [1-2]: " choice

    case $choice in
        1)
            turn_on_grass
            ;;
        2)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice!"
            show_menu
            ;;
    esac
}

# Run the menu
show_menu
