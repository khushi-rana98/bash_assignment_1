# Bash Health Monitor Script

## Author
Khushi 

## Overview
This is a Bash script that monitors system services, checks their status, and attempts to restart them if they fail. It also logs all activities and displays a summary.

## Features
- Reads services from `services.txt`
- Checks service status
- Restarts failed services
- Logs output with timestamp
- Displays summary report

## How to Run
```bash
chmod +x health_monitor.sh
./health_monitor.sh
