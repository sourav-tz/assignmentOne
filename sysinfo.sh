#!/usr/bin/env bash
# ==============================================================================
# sysinfo.sh - Linux System Information Report Script
# ==============================================================================
# Description:
#   Displays essential system information including hostname, date/time,
#   logged-in user, root disk usage, memory usage, and top 5 memory-consuming
#   processes. Also saves the report to a file named with today's date.
#
# Usage:
#   ./sysinfo.sh
#
# Cron Example (Run every hour at minute 0):
#   0 * * * * /path/to/assignment-1/sysinfo.sh >/dev/null 2>&1
# ==============================================================================

# Resolve the directory where this script is located so the dated output file
# is always saved predictably alongside the script (even when run via cron).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY="$(date "+%Y-%m-%d" 2>/dev/null || echo "unknown-date")"
OUTPUT_FILE="${SCRIPT_DIR}/sysinfo_${TODAY}.log"

# Helper function to print a consistent section header
print_header() {
    local title="$1"
    printf "\n[%s]\n" "$title"
    printf "%s\n" "------------------------------------------------------------"
}

# Helper function to print graceful error messages
print_error() {
    printf "Error: %s\n" "$1" >&2
}

# Build and print the complete system information report
generate_report() {
    printf "%s\n" "============================================================"
    printf "                  SYSTEM INFORMATION REPORT                 \n"
    printf "%s\n" "============================================================"

    # 1. Hostname of the system
    print_header "1. Hostname"
    if command -v hostname >/dev/null 2>&1; then
        hostname || print_error "Failed to retrieve system hostname."
    else
        print_error "'hostname' command is not available."
    fi

    # 2. Current date and time
    print_header "2. Current Date and Time"
    if command -v date >/dev/null 2>&1; then
        date "+%Y-%m-%d %H:%M:%S %Z (%A)" || print_error "Failed to retrieve current date and time."
    else
        print_error "'date' command is not available."
    fi

    # 3. Currently logged-in user
    print_header "3. Currently Logged-in User"
    if command -v whoami >/dev/null 2>&1; then
        whoami || print_error "Failed to retrieve current user."
    elif command -v id >/dev/null 2>&1; then
        id -un || print_error "Failed to retrieve current user."
    else
        print_error "Neither 'whoami' nor 'id' command is available."
    fi

    # 4. Disk usage of the root directory (/)
    print_header "4. Disk Usage of Root Directory (/)"
    if command -v df >/dev/null 2>&1; then
        df -h / || print_error "Failed to retrieve disk usage for '/'."
    else
        print_error "'df' command is not available."
    fi

    # 5. Memory usage (standard Linux 'free' utility)
    print_header "5. Memory Usage"
    if command -v free >/dev/null 2>&1; then
        if ! free -h 2>/dev/null; then
            # Fallback to megabytes on older Linux systems without 'free -h'
            free -m || print_error "Failed to retrieve memory usage."
        fi
    else
        print_error "'free' command not found. This section requires a Linux environment."
    fi

    # 6. Top 5 processes sorted by memory usage (GNU ps syntax on Linux)
    print_header "6. Top 5 Processes by Memory Usage"
    if command -v ps >/dev/null 2>&1; then
        # Capture ps output first to avoid SIGPIPE exit status from head
        if ps_output="$(ps -eo pid,user,%mem,%cpu,comm --sort=-%mem 2>/dev/null)"; then
            printf "%s\n" "$ps_output" | head -n 6
        else
            print_error "'ps --sort=-%mem' failed. Ensure this script is running in a Linux environment."
        fi
    else
        print_error "'ps' command is not available."
    fi

    printf "\n%s\n" "============================================================"
    printf "Report generated on: %s\n" "$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "N/A")"
    printf "%s\n" "============================================================"
}

# Main execution: display report on stdout and save to a dated file (Bonus)
if touch "$OUTPUT_FILE" 2>/dev/null; then
    generate_report | tee "$OUTPUT_FILE"
    printf "\n[Saved] Report written to: %s\n" "$OUTPUT_FILE"
else
    print_error "Unable to write output file '$OUTPUT_FILE'. Displaying report only."
    generate_report
fi
