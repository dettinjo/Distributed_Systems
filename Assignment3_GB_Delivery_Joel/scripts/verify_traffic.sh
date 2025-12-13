#!/bin/bash

# Get the URL from Terraform Output
TF_DIR="../terraform"
# Temporarily switch dir to get output, then switch back
URL=$(cd "$TF_DIR" && terraform output -raw traffic_manager_dns)

echo "---------------------------------------------------"
echo " Starting Advanced Load Balancer Test against:"
echo " $URL"
echo "---------------------------------------------------"
echo " Press [CTRL+C] to stop..."
echo ""

BLUE_COUNT=0
GREEN_COUNT=0
TOTAL=0

# Loop indefinitely
while true; do
    # -s: Silent mode, -L: Follow redirects, --max-time: Fail fast if stuck
    RESPONSE=$(curl -s -L --max-time 2 "$URL")
    
    # Check for the specific H1 tag content defined in your user_data
    if echo "$RESPONSE" | grep -q "Spain"; then
        ((BLUE_COUNT++))
        LAST_HIT="🔵 Blue (Spain)"
    elif echo "$RESPONSE" | grep -q "France"; then
        ((GREEN_COUNT++))
        LAST_HIT="🟢 Green (France)"
    else
        LAST_HIT="⚠️  Unknown/Error"
    fi

    ((TOTAL++))

    # Calculate integer percentages (avoid division by zero)
    if [ $TOTAL -gt 0 ]; then
        PERC_BLUE=$(( 100 * BLUE_COUNT / TOTAL ))
        PERC_GREEN=$(( 100 * GREEN_COUNT / TOTAL ))
    else
        PERC_BLUE=0
        PERC_GREEN=0
    fi

    # Print a dynamic status line (using \r to overwrite the line)
    printf "\rRequests: %-4d | Blue: %-3d (%3d%%) | Green: %-3d (%3d%%) | Last: %s   " \
        "$TOTAL" "$BLUE_COUNT" "$PERC_BLUE" "$GREEN_COUNT" "$PERC_GREEN" "$LAST_HIT"

    # Sleep slightly to allow DNS TTL to potentially expire during long runs
    sleep 0.5
done