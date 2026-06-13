#!/bin/bash

# -------------------------------------------------------
# Student Attendance Tracker - Project Setup
# Written by: AGASARO Nicia Greta
# Date: 13 June 2026
# i built this step by step, the trap part took me the longest
# -------------------------------------------------------

echo ""
echo "=========================================="
echo "   Attendance Tracker Setup - by AGASARO Nicia Greta"
echo "=========================================="
echo ""

read -p "Enter a name for your project (e.g. 'myclass' or 'semester1'): " user_input

# if they just press enter without typing anything, stop the script
if [[ -z "$user_input" ]]; then
    echo ""
    echo "ERROR: you did not type a project name, please run the script again"
    exit 1
fi

# this builds the folder name using whatever the user typed
PROJECT_DIR="attendance_tracker_${user_input}"

# check if the folder already exists so we dont accidentally delete someones work
if [[ -d "$PROJECT_DIR" ]]; then
    echo "WARNING: a folder called '$PROJECT_DIR' already exists"
    read -p "do you want to overwrite it? (yes/no): " overwrite_choice

    if [[ "$overwrite_choice" != "yes" ]]; then
        echo "okay, no changes were made, exiting now"
        exit 0
    fi

    rm -rf "$PROJECT_DIR"
    echo "old folder deleted, starting fresh..."
fi

# now create the folders we need
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

echo "  folders created successfully"
