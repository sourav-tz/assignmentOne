# MCA DevOps Assignment 1: Linux Shell Scripting and Git

A professional Linux shell scripting project containing two Bash automation utilities: a system information reporter (`sysinfo.sh`) and a web server access log analyzer (`log_report.sh`), structured and version-controlled with Git for public GitHub hosting.

---

## 1. Assignment Objectives

- Practice writing clean, readable, and POSIX/Bash-compliant shell scripts for Linux system administration.
- Gather and format core Linux system diagnostics (hostname, date/time, current user, disk usage, memory usage, and top memory-consuming processes).
- Parse and summarize web server access logs using standard Linux text-processing utilities (`awk`, `grep`, `sort`, `uniq`, `wc`, `head`).
- Implement defensive argument validation and graceful command error handling.
- Automate daily report saving and hourly scheduling with `cron`.
- Manage project source files using Git and prepare the repository for GitHub.

---

## 2. Project Directory Structure

```text
assignmentOne/
├── .gitignore
├── sysinfo.sh
├── log_report.sh
├── sample.log
└── README.md
```

---

## 3. Prerequisites

- **Operating System:** Linux environment (e.g., Ubuntu, Debian, RHEL, Fedora, or CentOS)
- **Shell:** GNU Bash (`bash`)
- **Standard Linux Utilities:**
  - For `sysinfo.sh`: `hostname`, `date`, `whoami` (or `id`), `df`, `free`, `ps`, `head`, `tee`
  - For `log_report.sh`: `awk`, `grep`, `sort`, `uniq`, `wc`, `head`
- **Version Control:** `git`

---

## 4. Instructions to Run `sysinfo.sh`

1. Navigate to the project directory:
   ```bash
   cd assignmentOne
   ```
2. Ensure the script has executable permissions:
   ```bash
   chmod +x sysinfo.sh
   ```
3. Execute the script:
   ```bash
   ./sysinfo.sh
   ```

The script displays a formatted system report on the terminal and saves a copy to `sysinfo_YYYY-MM-DD.log` in the script directory.

---

## 5. Instructions to Run `log_report.sh`

1. Ensure the script has executable permissions:
   ```bash
   chmod +x log_report.sh
   ```
2. Run the script with a log file path as its argument:
   ```bash
   ./log_report.sh sample.log
   ```
3. To view usage instructions:
   ```bash
   ./log_report.sh --help
   ```

If no file is provided, too many arguments are passed, or the target file does not exist / is unreadable, the script prints an informative error message and exits with a non-zero status code (`1`).

---

## 6. Explanation of Linux Commands Used

| Command | Purpose |
| :--- | :--- |
| `hostname` | Displays the system's network hostname. |
| `date` | Formats and prints the current system date and time (`+%Y-%m-%d %H:%M:%S %Z (%A)`). |
| `whoami` / `id -un` | Displays the username of the currently active/logged-in user. |
| `df -h /` | Reports human-readable disk space usage for the root (`/`) filesystem. |
| `free -h` | Displays total, used, free, and available RAM and swap memory in human-readable units (with `free -m` fallback). |
| `ps -eo pid,user,%mem,%cpu,comm --sort=-%mem` | Lists running processes with PID, owner, memory %, CPU %, and command name sorted in descending order of memory usage. |
| `grep` | Counts non-blank request lines (`grep -c -v`) and matches HTTP `404` status codes immediately following the quoted request (`grep -E`). |
| `awk` | Extracts the first column (client IP address) from each log entry and formats ranked output rows cleanly. |
| `sort` | Groups identical IP addresses for counting and orders counts numerically in descending order (`sort -k1,1nr -k2,2`). |
| `uniq -c` | Counts consecutive occurrences of each sorted IP address. |
| `wc -l` | Counts matching lines (used for HTTP `404` error totals). |
| `head -n` | Limits output to the top entries (top 5 processes with `head -n 6` including header; top 3 IPs with `head -n 3`). |
| `tee` | Writes output simultaneously to the terminal and to the daily log file. |

---

## 7. Sample Input and Output

### A. `sysinfo.sh`

**Command:**
```bash
./sysinfo.sh
```

**Illustrative Linux Output:**
```text
============================================================
                  SYSTEM INFORMATION REPORT                 
============================================================

[1. Hostname]
------------------------------------------------------------
ubuntu-devops-node

[2. Current Date and Time]
------------------------------------------------------------
2026-11-25 02:10:00 IST (Wednesday)

[3. Currently Logged-in User]
------------------------------------------------------------
ubuntu

[4. Disk Usage of Root Directory (/)]
------------------------------------------------------------
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   12G   36G  25% /

[5. Memory Usage]
------------------------------------------------------------
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       2.1Gi       3.4Gi       120Mi       2.3Gi       5.3Gi
Swap:          2.0Gi          0B       2.0Gi

[6. Top 5 Processes by Memory Usage]
------------------------------------------------------------
  PID USER     %MEM %CPU COMMAND
 1420 postgres  6.4  1.2 postgres
  982 node      4.8  2.5 node
  715 dockerd   3.2  0.8 dockerd
  512 systemd   1.1  0.1 systemd-journal
  401 sshd      0.6  0.0 sshd

============================================================
Report generated on: 2026-11-25 02:10:00
============================================================

[Saved] Report written to: /path/to/assignment-1/sysinfo_2026-11-25.log
```

### B. `log_report.sh`

**Sample Input (`sample.log`):**

> **Note:** `sample.log` contains representative sample Apache/Nginx Combined Log Format entries created for testing and demonstration purposes.

```text
192.168.1.10 - - [25/Nov/2026:08:01:12 +0000] "GET /index.html HTTP/1.1" 200 2048 "-" "Mozilla/5.0"
192.168.1.10 - - [25/Nov/2026:08:01:14 +0000] "GET /assets/style.css HTTP/1.1" 200 1024 "http://example.local/" "Mozilla/5.0"
10.0.0.15 - - [25/Nov/2026:08:02:05 +0000] "GET /login HTTP/1.1" 200 1536 "-" "curl/8.5.0"
192.168.1.10 - - [25/Nov/2026:08:03:20 +0000] "GET /missing-page.html HTTP/1.1" 404 196 "-" "Mozilla/5.0"
... (20 entries total)
```

**Command:**
```bash
./log_report.sh sample.log
```

**Observed Output:**
```text
============================================================
                    LOG ANALYSIS REPORT                     
============================================================
Log File            : sample.log
Generated On        : 2026-11-25 02:09:00 IST
------------------------------------------------------------
Total Requests      : 20
Total HTTP 404s     : 5
------------------------------------------------------------
Top 3 IP Addresses by Request Frequency:
  Rank IP Address         Requests
  ---- ------------------ --------
  1    192.168.1.10       7
  2    10.0.0.15          5
  3    172.16.0.42        4
============================================================
```

---

## 8. Bonus Features

### 1. Daily Dated Report Output

`sysinfo.sh` automatically saves each generated report to a file named with the current date (`sysinfo_YYYY-MM-DD.log`) in the script's directory using `tee`, while simultaneously printing the report to standard output.

### 2. Hourly Cron Job Configuration

To execute `sysinfo.sh` automatically every hour (at minute `0`), open the crontab editor:

```bash
crontab -e
```

Add the following entry (replace `/absolute/path/to/assignmentOne` with your actual directory path):

```cron
0 * * * * /absolute/path/to/assignmentOne/sysinfo.sh >/dev/null 2>&1
```

Because `sysinfo.sh` writes its own dated file (`sysinfo_YYYY-MM-DD.log`), redirecting cron stdout/stderr avoids unnecessary cron mail while preserving the daily report file.

---

## 9. GitHub Repository Information

- **Repository URL:** `https://github.com/sourav-tz/assignmentOne` *(placeholder — update after creating the public GitHub repository)*
- **Default Branch:** `main`
