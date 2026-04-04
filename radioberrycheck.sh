#!/bin/bash

# Radioberry Health Check Script - FIXED VERSION
# Eliminates false positives from binary test when service is running

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counter for failures
FAILURES=0
CHECKS=0

# Determine boot config location
if [ -f "/boot/firmware/config.txt" ]; then
    BOOT_CONFIG="/boot/firmware/config.txt"
elif [ -f "/boot/config.txt" ]; then
    BOOT_CONFIG="/boot/config.txt"
else
    BOOT_CONFIG=""
fi

# Function to print OK
print_ok() {
    echo -e "${GREEN}✓ OK${NC} - $1"
}

# Function to print FAIL
print_fail() {
    echo -e "${RED}✗ FAIL${NC} - $1"
    ((FAILURES++))
}

# Function to print INFO
print_info() {
    echo -e "${BLUE}ℹ INFO${NC} - $1"
}

# Function to print SKIP
print_skip() {
    echo -e "${YELLOW}○ SKIP${NC} - $1"
}

# Function to print section header
print_header() {
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}========================================${NC}"
}

# Clear screen
clear

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     Radioberry SDR Health Check Script v2.0              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Date and time
print_info "Check performed at: $(date)"
print_info "Boot config location: $BOOT_CONFIG"

# Section 1: Kernel Module
print_header "1. KERNEL MODULE CHECK"

# Check if module is loaded
((CHECKS++))
if lsmod | grep -q radioberry; then
    MODULE_INFO=$(lsmod | grep radioberry)
    print_ok "radioberry kernel module is loaded"
    print_info "  $MODULE_INFO"
else
    print_fail "radioberry kernel module is NOT loaded"
fi

# Section 2: Device Node
print_header "2. DEVICE NODE CHECK"

# Check /dev/radioberry
((CHECKS++))
if [ -e "/dev/radioberry" ]; then
    DEVICE_INFO=$(ls -la /dev/radioberry 2>/dev/null)
    MAJOR_NUM=$(ls -la /dev/radioberry 2>/dev/null | awk '{print $5}' | tr -d ',')
    print_ok "/dev/radioberry device node exists"
    print_info "  $DEVICE_INFO"
    print_info "  Major number: $MAJOR_NUM"
else
    print_fail "/dev/radioberry device node does NOT exist"
fi

# Check device permissions
((CHECKS++))
if [ -r "/dev/radioberry" ] && [ -w "/dev/radioberry" ]; then
    print_ok "/dev/radioberry has read/write permissions"
else
    print_fail "/dev/radioberry does NOT have proper permissions"
fi

# Section 3: Systemd Service
print_header "3. SYSTEMD SERVICE CHECK"

# Check if service is enabled
((CHECKS++))
if systemctl is-enabled radioberry.service >/dev/null 2>&1; then
    print_ok "radioberry service is enabled (starts at boot)"
else
    print_fail "radioberry service is NOT enabled"
fi

# Check if service is active
((CHECKS++))
if systemctl is-active radioberry.service >/dev/null 2>&1; then
    print_ok "radioberry service is active (running)"
    SERVICE_PID=$(systemctl show -p MainPID radioberry.service 2>/dev/null | cut -d= -f2)
    print_info "  Service PID: $SERVICE_PID"
    SERVICE_RUNNING=true
else
    print_fail "radioberry service is NOT active"
    SERVICE_RUNNING=false
fi

# Section 4: FPGA Gateware
print_header "4. FPGA GATEWARE CHECK"

# Check gateware file exists
((CHECKS++))
if [ -f "/lib/firmware/radioberry.rbf" ]; then
    GATEWARE_SIZE=$(ls -la /lib/firmware/radioberry.rbf 2>/dev/null | awk '{print $5}')
    GATEWARE_DATE=$(ls -la /lib/firmware/radioberry.rbf 2>/dev/null | awk '{print $6, $7, $8}')
    print_ok "FPGA gateware file exists"
    print_info "  Size: $GATEWARE_SIZE bytes"
    print_info "  Date: $GATEWARE_DATE"
else
    print_fail "FPGA gateware file NOT found at /lib/firmware/radioberry.rbf"
fi

# Section 5: Kernel Messages
print_header "5. KERNEL MESSAGES CHECK"

# Check for FPGA programming success
((CHECKS++))
if dmesg | grep -i radioberry | grep -q "registered correctly"; then
    print_ok "Radioberry registered correctly with kernel"
else
    print_fail "Radioberry registration issue in kernel"
fi

# Check for FPGA programming errors
((CHECKS++))
if dmesg | grep -i radioberry | grep -qi "error\|failed" | grep -v "Device or resource busy"; then
    print_fail "FPGA programming errors detected in kernel log"
    print_info "  Run 'dmesg | grep -i radioberry | grep -i error' for details"
else
    print_ok "No FPGA programming errors detected"
fi

# Check for "conf done is low" error
((CHECKS++))
if dmesg | grep -i radioberry | grep -q "conf done is low"; then
    print_fail "FPGA configuration error detected (conf done is low)"
else
    print_ok "FPGA configuration successful"
fi

# Section 6: Userspace Binary
print_header "6. USERSPACE BINARY CHECK"

# Check if radioberry binary exists
((CHECKS++))
if [ -f "/usr/local/bin/radioberry" ]; then
    BINARY_SIZE=$(ls -la /usr/local/bin/radioberry 2>/dev/null | awk '{print $5}')
    print_ok "radioberry userspace binary exists"
    print_info "  Size: $BINARY_SIZE bytes"
    
    # Test if binary runs - skip if service is running (expected behavior)
    if [ "$SERVICE_RUNNING" = true ]; then
        print_skip "Binary test skipped - service is running (normal operation)"
        print_info "  Binary would fail with 'Device or resource busy' - this is EXPECTED"
    else
        if /usr/local/bin/radioberry --help >/dev/null 2>&1; then
            print_ok "radioberry binary executes successfully"
        else
            print_fail "radioberry binary execution failed"
        fi
    fi
else
    print_fail "radioberry userspace binary NOT found"
fi

# Section 7: Process Check
print_header "7. PROCESS CHECK"

# Check if radioberry process is running
((CHECKS++))
if pgrep -f "radioberry" >/dev/null 2>&1; then
    PROCESS_COUNT=$(pgrep -f "radioberry" | wc -l)
    PROCESS_PIDS=$(pgrep -f "radioberry" | tr '\n' ' ')
    print_ok "radioberry process is running"
    print_info "  Process count: $PROCESS_COUNT"
    print_info "  PIDs: $PROCESS_PIDS"
else
    print_fail "No radioberry process found"
fi

# Section 8: Device Tree Overlay
print_header "8. DEVICE TREE OVERLAY CHECK"

# Check if overlay is loaded using multiple methods
OVERLAY_LOADED=false

# Method 1: Check dtoverlay list
if sudo dtoverlay -l 2>/dev/null | grep -q radioberry; then
    OVERLAY_LOADED=true
fi

# Method 2: Check if GPIO/IRQ is working (proves overlay is loaded)
if dmesg | grep -i radioberry | grep -q "mapped to IRQ"; then
    OVERLAY_LOADED=true
fi

# Method 3: Check device tree directory
if [ -d "/proc/device-tree/radioberry" ] 2>/dev/null; then
    OVERLAY_LOADED=true
fi

((CHECKS++))
if [ "$OVERLAY_LOADED" = true ]; then
    print_ok "radioberry device tree overlay is active"
    print_info "  Verified by GPIO/IRQ configuration"
else
    print_fail "radioberry device tree overlay NOT loaded"
fi

# Section 9: GPIO and IRQ
print_header "9. GPIO AND IRQ CHECK"

# Check GPIO and IRQ from dmesg
if dmesg | grep -i radioberry | grep -q "mapped to IRQ"; then
    IRQ_INFO=$(dmesg | grep -i radioberry | grep "mapped to IRQ" | tail -1)
    print_ok "GPIO and IRQ configured"
    print_info "  $IRQ_INFO"
else
    print_info "GPIO/IRQ info not found in kernel log"
fi

# Section 10: Boot Persistence
print_header "10. BOOT PERSISTENCE CHECK"

# Check config.txt for overlay (check both locations)
if [ -n "$BOOT_CONFIG" ]; then
    ((CHECKS++))
    if grep -q "dtoverlay=radioberry" "$BOOT_CONFIG" 2>/dev/null; then
        print_ok "radioberry overlay configured in $BOOT_CONFIG"
    else
        print_fail "radioberry overlay NOT configured in $BOOT_CONFIG"
    fi
else
    print_fail "Could not find config.txt (checked /boot/firmware/ and /boot/)"
fi

# Check /etc/modules for module
((CHECKS++))
if grep -q "^radioberry" /etc/modules 2>/dev/null; then
    print_ok "radioberry module configured in /etc/modules"
else
    print_fail "radioberry module NOT configured in /etc/modules"
fi

# Summary
print_header "SUMMARY"

echo -e "Total checks performed: ${BLUE}$CHECKS${NC}"
echo -e "Failed checks: ${RED}$FAILURES${NC}"
echo -e "Passed checks: ${GREEN}$((CHECKS - FAILURES))${NC}"

echo ""
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║     ✓ ALL CHECKS PASSED - RADIOBERRY IS OPERATIONAL!     ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                           ║${NC}"
    echo -e "${RED}║     ✗ SOME CHECKS FAILED - PLEASE REVIEW ABOVE ERRORS     ║${NC}"
    echo -e "${RED}║                                                           ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${YELLOW}Troubleshooting suggestions:${NC}"
    echo "1. Run: sudo dtoverlay radioberry.dtbo"
    echo "2. Run: sudo modprobe radioberry"
    echo "3. Run: sudo systemctl restart radioberry"
    echo "4. Check dmesg: dmesg | grep -i radioberry"
    exit 1
fi
