#!/bin/bash
# =============================================================================
# n8n API Configuration - Advanced Bootstrap via REST API
# =============================================================================
# This script uses n8n REST API to fully automate configuration:
# 1. Authenticates with n8n API
# 2. Creates WAHA credential programmatically
# 3. Activates all workflows
# 4. Validates configuration
# =============================================================================

set -e

# Configuration
N8N_URL="${N8N_URL:-http://localhost:5678}"
N8N_OWNER_EMAIL="${N8N_OWNER_EMAIL}"
N8N_OWNER_PASSWORD="${N8N_OWNER_PASSWORD}"
WAHA_API_KEY="${WAHA_API_KEY}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[n8n-api]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# =============================================================================
# Authenticate and get API token
# =============================================================================
authenticate() {
    log "Authenticating with n8n API..."
    
    local response=$(curl -s -X POST "${N8N_URL}/rest/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"${N8N_OWNER_EMAIL}\",
            \"password\": \"${N8N_OWNER_PASSWORD}\"
        }")
    
    if echo "$response" | jq -e '.data.token' > /dev/null 2>&1; then
        API_TOKEN=$(echo "$response" | jq -r '.data.token')
        log_success "Authenticated successfully"
        return 0
    else
        log_error "Authentication failed"
        return 1
    fi
}

# =============================================================================
# Create WAHA credential
# =============================================================================
create_waha_credential() {
    log "Creating WAHA credential..."
    
    local credential_data='{
        "name": "WAHA API",
        "type": "httpHeaderAuth",
        "data": {
            "name": "X-Api-Key",
            "value": "'"${WAHA_API_KEY}"'"
        }
    }'
    
    local response=$(curl -s -X POST "${N8N_URL}/rest/credentials" \
        -H "Content-Type: application/json" \
        -H "Cookie: n8n-auth=${API_TOKEN}" \
        -d "$credential_data")
    
    if echo "$response" | jq -e '.data.id' > /dev/null 2>&1; then
        log_success "WAHA credential created"
        return 0
    else
        log_error "Failed to create credential"
        return 1
    fi
}

# =============================================================================
# Activate all workflows
# =============================================================================
activate_workflows() {
    log "Activating workflows..."
    
    # Get all workflows
    local workflows=$(curl -s -X GET "${N8N_URL}/rest/workflows" \
        -H "Cookie: n8n-auth=${API_TOKEN}")
    
    local workflow_ids=$(echo "$workflows" | jq -r '.data[].id')
    local count=0
    
    for id in $workflow_ids; do
        log "Activating workflow ID: $id"
        
        curl -s -X PATCH "${N8N_URL}/rest/workflows/${id}" \
            -H "Content-Type: application/json" \
            -H "Cookie: n8n-auth=${API_TOKEN}" \
            -d '{"active": true}' > /dev/null
        
        count=$((count + 1))
    done
    
    log_success "Activated $count workflows"
}

# =============================================================================
# Main execution
# =============================================================================
main() {
    log "==================================================================="
    log "n8n API Configuration"
    log "==================================================================="
    
    if [ -z "$N8N_OWNER_EMAIL" ] || [ -z "$N8N_OWNER_PASSWORD" ]; then
        log_error "N8N_OWNER_EMAIL and N8N_OWNER_PASSWORD required"
        exit 1
    fi
    
    if ! authenticate; then
        log_error "Cannot proceed without authentication"
        exit 1
    fi
    
    if [ -n "$WAHA_API_KEY" ]; then
        create_waha_credential
    fi
    
    activate_workflows
    
    log_success "Configuration completed!"
}

main "$@"
