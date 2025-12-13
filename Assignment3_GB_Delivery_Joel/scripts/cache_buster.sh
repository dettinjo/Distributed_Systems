#!/bin/bash
echo "TIMESTAMP            | RESOLVED IP      | REGION"
echo "---------------------|------------------|-----------------------"
for i in {1..20}; do 
    # Get the Load Balancer URL without http://
    # Get the URL from Terraform Output
    TF_DIR="../terraform"
    # Temporarily switch dir to get output, then switch back
    URL=$(cd "$TF_DIR" && terraform output -raw traffic_manager_dns)
    DOMAIN=$(echo "$URL" | sed 's|http://||')
    
    # 1. Resolve the IP explicitly (bypass some local caching)
    IP=$(dig +short "$DOMAIN" | head -n 1)
    
    # 2. Ask that specific IP who it is
    CONTENT=$(curl -s -H "Host: $DOMAIN" "http://$IP")
    
    if echo "$CONTENT" | grep -q "Spain"; then 
        REGION="🔵 Blue (Spain)"
    elif echo "$CONTENT" | grep -q "France"; then 
        REGION="🟢 Green (France)"
    else 
        REGION="⚠️  Unknown"
    fi
    
    printf "%s | %-16s | %s\n" "$(date +%H:%M:%S)" "$IP" "$REGION"
    
    # Slight pause
    sleep 1
done