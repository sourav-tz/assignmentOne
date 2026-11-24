#!/usr/bin/env bash
# ==============================================================================
# log_report.sh - Web Server Log Analysis Script
# ==============================================================================
# Description:
#   Parses a standard Apache/Nginx access log file and prints a summary report
#   containing:
#     1. Total number of requests
#     2. Total number of HTTP 404 errors
#     3. Top 3 IP addresses by request frequency
#
# Usage:
#   ./log_report.sh <log_file>
# ==============================================================================

# Print usage instructions
usage() {
    cat <<EOF
Usage: $(basename "$0") <log_file>

Analyze an access log file and generate a summary report.

Arguments:
  <log_file>    Path to a readable web server access log file (e.g., sample.log)

Options:
  -h, --help    Display this help message and exit

Example:
  ./$(basename "$0") sample.log
EOF
}

# Handle help flag if provided as the first argument
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Validate that exactly one argument (the log file path) was provided
if [[ $# -eq 0 ]]; then
    printf "Error: No log file specified.\n\n" >&2
    usage >&2
    exit 1
elif [[ $# -gt 1 ]]; then
    printf "Error: Too many arguments provided (expected 1, got %d).\n\n" "$#" >&2
    usage >&2
    exit 1
fi

LOG_FILE="$1"

# Validate that the target exists, is a regular file, and is readable
if [[ ! -e "$LOG_FILE" ]]; then
    printf "Error: Log file '%s' does not exist.\n" "$LOG_FILE" >&2
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    printf "Error: '%s' is not a regular file.\n" "$LOG_FILE" >&2
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    printf "Error: Log file '%s' is not readable. Check file permissions.\n" "$LOG_FILE" >&2
    exit 1
fi

# Verify that required standard utilities are available
for cmd in awk grep sort uniq wc head; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "Error: Required command '%s' was not found.\n" "$cmd" >&2
        exit 1
    fi
done

# 1. Calculate total number of requests (non-empty lines in the log file).
#    'grep -c -v' exits with status 1 when the count is 0, so '|| true' keeps
#    the script from treating an empty/all-whitespace file as an error.
total_requests="$(grep -c -v '^[[:space:]]*$' "$LOG_FILE" || true)"

# 2. Calculate total number of HTTP 404 errors.
#    Matches the 404 status code immediately following the quoted HTTP request
#    (e.g., "GET /missing HTTP/1.1" 404 196) so '404' inside URLs or byte sizes
#    is not falsely counted.
total_404="$(grep -E '^[^"]*"[^"]*"[[:space:]]+404([[:space:]]|$)' "$LOG_FILE" | wc -l | awk '{print $1}')"

# 3. Determine top 3 IP addresses by request frequency.
#    - awk extracts field 1 (client IP) from every non-empty line
#    - sort groups identical IPs before counting
#    - uniq -c counts consecutive occurrences of each IP
#    - sort -k1,1nr -k2,2 sorts descending by count, then ascending by IP
#    - head -n 3 keeps only the top 3 entries
top_ips="$(awk 'NF {print $1}' "$LOG_FILE" | sort | uniq -c | sort -k1,1nr -k2,2 | head -n 3)"

# Format and display the report
printf "%s\n" "============================================================"
printf "                    LOG ANALYSIS REPORT                     \n"
printf "%s\n" "============================================================"
printf "Log File            : %s\n" "$LOG_FILE"
printf "Generated On        : %s\n" "$(date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null || echo "N/A")"
printf "%s\n" "------------------------------------------------------------"
printf "Total Requests      : %s\n" "$total_requests"
printf "Total HTTP 404s     : %s\n" "$total_404"
printf "%s\n" "------------------------------------------------------------"
printf "Top 3 IP Addresses by Request Frequency:\n"
printf "  %-4s %-18s %s\n" "Rank" "IP Address" "Requests"
printf "  %-4s %-18s %s\n" "----" "------------------" "--------"

if [[ -n "$top_ips" ]]; then
    # Format each ranked entry cleanly using awk
    printf "%s\n" "$top_ips" | awk '{ printf "  %-4d %-18s %s\n", NR, $2, $1 }'
else
    printf "  No IP entries found in log file.\n"
fi

printf "%s\n" "============================================================"
