#!/bin/bash

# Traffic Management Script for Blue/Green Deployment
# Usage: ./manage-traffic.sh [blue|green|split]

RESOURCE_GROUP="rg-blue-green-deployment"
APP_GATEWAY_NAME=$(az network application-gateway list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)

case $1 in
  "blue")
    echo "Switching all traffic to BLUE environment..."
    az network application-gateway rule update \
      --resource-group $RESOURCE_GROUP \
      --gateway-name $APP_GATEWAY_NAME \
      --name blue-routing-rule \
      --address-pool blue-backend-pool
    echo "Traffic now routed to Blue environment"
    ;;
  
  "green")
    echo "Switching all traffic to GREEN environment..."
    az network application-gateway rule update \
      --resource-group $RESOURCE_GROUP \
      --gateway-name $APP_GATEWAY_NAME \
      --name blue-routing-rule \
      --address-pool green-backend-pool
    echo "Traffic now routed to Green environment"
    ;;
    
  "status")
    echo "Current Application Gateway configuration:"
    az network application-gateway show \
      --resource-group $RESOURCE_GROUP \
      --name $APP_GATEWAY_NAME \
      --query "requestRoutingRules[0].{Name:name,BackendPool:backendAddressPool.id}" \
      --output table
    ;;
    
  *)
    echo "Usage: $0 [blue|green|status]"
    echo "  blue   - Route all traffic to blue environment"
    echo "  green  - Route all traffic to green environment"
    echo "  status - Show current routing configuration"
    ;;
esac
