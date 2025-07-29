#!/bin/bash

# Define the email address to send reports to
REPORT_EMAIL="jbacker@gmail.com"

# Define the path to the smartctl executable (adjust if necessary)
SMARTCTL_PATH="/usr/sbin/smartctl"

# Get a list of all block devices (disks)
DISKS=$(lsblk -dno NAME | grep -E 'sd[a-z]|nvme[0-9]n[0-9]')

# Initialize an empty variable to store the report
SMART_REPORT=""

# Loop through each detected disk
for DISK in $DISKS; do
    DEVICE="/dev/$DISK"

    # Check if the device exists and is a block device
    if [[ -b "$DEVICE" ]]; then
        SMART_REPORT+="--- S.M.A.R.T. Report for $DEVICE ---\n"

        # Get important S.M.A.R.T. attributes (e.g., Reallocated_Sector_Ct, Current_Pending_Sector)
        #SMART_REPORT+="$($SMARTCTL_PATH -A "$DEVICE" | grep -E 'Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable|Temperature_Celsius' 2>&1)\n\n"
        SMART_REPORT+="$($SMARTCTL_PATH -ai "$DEVICE" | grep -E 'SMART overall-health self-assessment test result:|Temperature:|Power Cycles:|Power On Hours:|Unsafe Shutdowns:|Error Information Log Entries:' 2>&>
    fi
done

# Send the report via email (requires a mail client like 'mailx' or 'sendmail')
echo -e "$SMART_REPORT" | mail -s "Daily S.M.A.R.T. Disk Report" "$REPORT_EMAIL"

exit 0
