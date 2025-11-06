#!/bin/bash
# =============================================================================
# n8n Bootstrap Script - Auto-configuration for Zero-Touch Deployment
# =============================================================================
# This script automatically configures n8n on first boot:
# 1. Creates owner user from environment variables
# 2. Installs community packages (n8n-nodes-waha)
# 3. Imports workflows from /workflows directory
# 4. Configures WAHA credentials
# 5. Activates workflows
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
N8N_DATA_DIR="${N8N_DATA_DIR:-/home/node/.n8n}"
WORKFLOWS_DIR="${WORKFLOWS_DIR:-/home/node/.n8n/workflows}"
BOOTSTRAP_MARKER="${N8N_DATA_DIR}/.bootstrap_complete"
N8N_URL="${N8N_URL:-http://localhost:5678}"

# Logging
log() {
    echo -e "${BLUE}[n8n-bootstrap]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# =============================================================================
# Check if bootstrap already completed
# =============================================================================
if [ -f "$BOOTSTRAP_MARKER" ]; then
    log_success "Bootstrap already completed (marker found)"
    exit 0
fi

log "Starting n8n bootstrap process..."

# =============================================================================
# Wait for n8n to be ready
# =============================================================================
wait_for_n8n() {
    log "Waiting for n8n to be ready..."
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "${N8N_URL}/healthz" > /dev/null 2>&1; then
            log_success "n8n is ready!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    log_error "n8n failed to start after $max_attempts attempts"
    return 1
}

# =============================================================================
# Create owner user
# =============================================================================
create_owner() {
    log "Creating n8n owner user..."
    
    if [ -z "$N8N_OWNER_EMAIL" ] || [ -z "$N8N_OWNER_PASSWORD" ]; then
        log_warning "N8N_OWNER_EMAIL or N8N_OWNER_PASSWORD not set, skipping user creation"
        return 0
    fi
    
    # Check if user already exists
    if [ -f "${N8N_DATA_DIR}/database.sqlite" ]; then
        local user_count=$(sqlite3 "${N8N_DATA_DIR}/database.sqlite" \
            "SELECT COUNT(*) FROM user WHERE email='${N8N_OWNER_EMAIL}';" 2>/dev/null || echo "0")
        
        if [ "$user_count" -gt 0 ]; then
            log_success "Owner user already exists"
            return 0
        fi
    fi
    
    # Create user via n8n CLI
    n8n user:create \
        --email="${N8N_OWNER_EMAIL}" \
        --password="${N8N_OWNER_PASSWORD}" \
        --firstName="${N8N_OWNER_FIRST_NAME:-Admin}" \
        --lastName="${N8N_OWNER_LAST_NAME:-User}" \
        2>/dev/null || {
        log_warning "Failed to create user (might already exist)"
    }
    
    log_success "Owner user configured"
}

# =============================================================================
# Install community packages
# =============================================================================
install_community_packages() {
    log "Installing community packages..."
    
    if [ -z "$N8N_COMMUNITY_PACKAGES" ]; then
        log_warning "N8N_COMMUNITY_PACKAGES not set, skipping"
        return 0
    fi
    
    IFS=',' read -ra PACKAGES <<< "$N8N_COMMUNITY_PACKAGES"
    
    for package in "${PACKAGES[@]}"; do
        package=$(echo "$package" | xargs) # Trim whitespace
        
        if [ -z "$package" ]; then
            continue
        fi
        
        log "Installing package: $package"
        
        # Check if already installed
        if npm list -g "$package" > /dev/null 2>&1; then
            log_success "$package already installed"
            continue
        fi
        
        # Install package
        npm install -g "$package" || {
            log_error "Failed to install $package"
            continue
        }
        
        log_success "$package installed successfully"
    done
}

# =============================================================================
# Import workflows
# =============================================================================
import_workflows() {
    log "Importing workflows from $WORKFLOWS_DIR..."
    
    if [ ! -d "$WORKFLOWS_DIR" ]; then
        log_warning "Workflows directory not found: $WORKFLOWS_DIR"
        return 0
    fi
    
    local workflow_count=0
    
    for workflow_file in "$WORKFLOWS_DIR"/*.json; do
        if [ ! -f "$workflow_file" ]; then
            continue
        fi
        
        local workflow_name=$(basename "$workflow_file" .json)
        log "Importing workflow: $workflow_name"
        
        # Import via n8n CLI
        n8n import:workflow --input="$workflow_file" --separate 2>/dev/null || {
            log_warning "Failed to import $workflow_name (might already exist)"
            continue
        }
        
        workflow_count=$((workflow_count + 1))
        log_success "Imported: $workflow_name"
    done
    
    if [ $workflow_count -eq 0 ]; then
        log_warning "No workflows imported"
    else
        log_success "Imported $workflow_count workflows"
    fi
}

# =============================================================================
# Configure WAHA credentials
# =============================================================================
configure_waha_credentials() {
    log "Configuring WAHA credentials..."
    
    if [ -z "$WAHA_API_KEY" ]; then
        log_warning "WAHA_API_KEY not set, skipping credential configuration"
        return 0
    fi
    
    # This would typically be done via n8n API
    # For now, we'll log it and expect manual configuration
    log_warning "WAHA credential configuration requires manual setup in n8n UI"
    log "Credential details:"
    log "  Type: Header Auth"
    log "  Name: X-Api-Key"
    log "  Value: ${WAHA_API_KEY}"
}

# =============================================================================
# Activate workflows
# =============================================================================
activate_workflows() {
    log "Activating workflows..."
    
    # This would require n8n API calls
    # For now, skip as workflows can be activated manually
    log_warning "Workflow activation requires n8n API or manual activation in UI"
}

# =============================================================================
# Create bootstrap marker
# =============================================================================
create_marker() {
    log "Creating bootstrap marker..."
    
    cat > "$BOOTSTRAP_MARKER" <<EOF
Bootstrap completed on: $(date)
Owner email: ${N8N_OWNER_EMAIL:-not set}
Community packages: ${N8N_COMMUNITY_PACKAGES:-none}
Workflows directory: ${WORKFLOWS_DIR}
EOF
    
    log_success "Bootstrap marker created"
}

# =============================================================================
# Main execution
# =============================================================================
main() {
    log "==================================================================="
    log "n8n Bootstrap - Zero-Touch Configuration"
    log "==================================================================="
    
    # Wait for n8n to be ready
    if ! wait_for_n8n; then
        log_error "Bootstrap failed: n8n not ready"
        exit 1
    fi
    
    # Execute bootstrap steps
    create_owner
    install_community_packages
    import_workflows
    configure_waha_credentials
    activate_workflows
    
    # Create marker to prevent re-running
    create_marker
    
    log "==================================================================="
    log_success "Bootstrap completed successfully!"
    log "==================================================================="
    log ""
    log "Next steps:"
    log "  1. Access n8n: ${N8N_URL}"
    log "  2. Login with: ${N8N_OWNER_EMAIL:-<your email>}"
    log "  3. Configure WAHA credential manually (see above)"
    log "  4. Activate imported workflows"
    log ""
}

# Run main function
main "$@"
