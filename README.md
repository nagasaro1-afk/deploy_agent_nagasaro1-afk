# Attendance Tracker - Project Setup Script
Written by: AGASARO Nicia Greta
Date: 13 June 2026

## What This Script Does

this script sets up everything automatically so i dont have to create folders and files one by one manually. it creates the full folder structure, lets you update the attendance thresholds, checks if python3 is installed and also handles ctrl+c cleanly.

## How to Run the Script

1. give it permission to run:
chmod +x setup_project.sh

2. then run it:
./setup_project.sh

3. follow the prompts:
- type a project name like myclass or semester1
- choose if you want to change the warning and failure thresholds
- the script does the rest

## How to Trigger the Archive Feature

to test the ctrl+c trap:
1. run the script: ./setup_project.sh
2. when it pauses asking about thresholds, press Ctrl+C
3. it will save whatever was built into a .tar.gz archive and delete the incomplete folder

## Requirements

- bash terminal (linux)
- python3 (the script checks this for you)

## Video Walkthrough

https://youtu.be/dCKenFfQZNI
