#!/usr/bin/env bash
set -uo pipefail

SERVICES_FILE="services.txt"
LOG_FILE="/tmp/health_monitor.log"
RESTART_WAIT=5

total=0
healthy=0
recovered=0
failed=0

# -------------------------------
# Display User Info (for uniqueness)
# -------------------------------
echo "User: Khushi"
echo "Host: $(hostname)"

# -------------------------------
# Logging function
# -------------------------------
log() {
    local level="$1"
    local message="$2"
    local service="${3:-system}"

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf "%s [%-5s] [%-20s] %s\n" "$timestamp" "$level" "$service" "$message" | tee -a "$LOG_FILE"
}

trap 'log INFO "Health monitor exited"' EXIT

# -------------------------------
# Service check function
# -------------------------------
check_service() {
    local service="$1"

    total=$((total + 1))

    if service "$service" status > /dev/null 2>&1; then
        log "OK" "Service is healthy" "$service"
        healthy=$((healthy + 1))
    else
        log "WARN" "Service is down -- attempting restart" "$service"

        service "$service" restart > /dev/null 2>&1
        sleep "$RESTART_WAIT"

        if service "$service" status > /dev/null 2>&1; then
            log "OK" "Service RECOVERED after restart" "$service"
            recovered=$((recovered + 1))
        else
            log "ERROR" "Service FAILED to restart" "$service"
            failed=$((failed + 1))
        fi
    fi
}

# -------------------------------
# Start execution
# -------------------------------
log "INFO" "Starting health monitor"

# Check file
if [[ ! -f "$SERVICES_FILE" ]]; then
    log "ERROR" "Services file not found"
    exit 1
fi

if [[ ! -s "$SERVICES_FILE" ]]; then
    log "WARN" "Services file is empty"
    exit 0
fi

# Loop through services
while IFS= read -r service; do
    [[ -z "$service" || "$service" == \#* ]] && continue
    check_service "$service"
done < "$SERVICES_FILE"

# -------------------------------
# Summary
# -------------------------------
echo "======================================"
echo "Health Monitor Summary"
echo "======================================"
printf ' %-16s: %d\n' "Total services" "$total"
printf ' %-16s: %d\n' "Healthy" "$healthy"
printf ' %-16s: %d\n' "Recovered" "$recovered"
printf ' %-16s: %d\n' "Failed" "$failed"
echo "======================================"
