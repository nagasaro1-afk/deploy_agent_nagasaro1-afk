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

PROJECT_DIR="attendance_tracker_${user_input}"
ARCHIVE_NAME="attendance_tracker_${user_input}_archive"

# this was the hardest part - ctrl+c now runs my cleanup function instead of just stopping
cleanup_on_cancel() {
    echo ""
    echo "-------------------------------------------"
    echo "  you pressed Ctrl+C, saving what was built so far..."
    echo "-------------------------------------------"

    if [[ -d "$PROJECT_DIR" ]]; then
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"
        echo "  archive saved as: ${ARCHIVE_NAME}.tar.gz"
        rm -rf "$PROJECT_DIR"
        echo "  incomplete folder deleted: $PROJECT_DIR"
    else
        echo "  nothing to archive, folder was not created yet"
    fi

    echo ""
    echo "  all cleaned up, exiting now"
    echo "-------------------------------------------"
    exit 1
}

trap cleanup_on_cancel SIGINT

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

mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
echo "  folders created successfully"

cat > "$PROJECT_DIR/attendance_checker.py" << 'PYTHON_END'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # basically just dividing attended by total then multiplying to get the percentage
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYTHON_END
echo "  attendance_checker.py created"

cat > "$PROJECT_DIR/Helpers/assets.csv" << 'CSV_END'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSV_END
echo "  assets.csv created"

cat > "$PROJECT_DIR/Helpers/config.json" << 'JSON_END'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSON_END
echo "  config.json created"

cat > "$PROJECT_DIR/reports/reports.log" << 'LOG_END'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
LOG_END
echo "  reports.log created"

echo ""
echo "-------------------------------------------"
echo "  default thresholds are Warning: 75%  and Failure: 50%"
echo "-------------------------------------------"

read -p "do you want to change the thresholds? (yes/no): " change_config

if [[ "$change_config" == "yes" ]]; then

    while true; do
        read -p "enter new Warning threshold (numbers only e.g. 70): " new_warning
        if [[ "$new_warning" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            break
        else
            echo "  that is not a valid number, try again"
        fi
    done

    while true; do
        read -p "enter new Failure threshold (numbers only e.g. 45): " new_failure
        if [[ "$new_failure" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            break
        else
            echo "  that is not a valid number, try again"
        fi
    done

    # sed edits the file directly, -i means save the changes in the file itself
    sed -i "s/\"warning\": [0-9.]*/\"warning\": $new_warning/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9.]*/\"failure\": $new_failure/" "$PROJECT_DIR/Helpers/config.json"

    echo "  config updated, Warning: ${new_warning}%  Failure: ${new_failure}%"

else
    echo "  keeping the default thresholds"
fi
