#!/bin/bash

# Quick Test Script for Janet
# This script performs basic health checks on the Janet system

echo "================================================"
echo "       Janet AI Assistant - Quick Test"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to test and report
test_and_report() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name... "

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

echo "Phase 1: Container Health Checks"
echo "---------------------------------"

test_and_report "Docker Compose installed" "which docker-compose"
test_and_report "Janet container running" "docker-compose ps | grep janet-assistant | grep -q Up"
test_and_report "MySQL container running" "docker-compose ps | grep janet-mysql | grep -q Up"

echo ""
echo "Phase 2: WordPress Tests"
echo "------------------------"

test_and_report "WordPress HTTP accessible" "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 | grep -qE '200|302'"
test_and_report "WordPress installed" "docker exec janet-assistant wp core is-installed --allow-root --path=/var/www/wordpress 2>/dev/null"
test_and_report "WordPress database connected" "docker exec janet-assistant wp db check --allow-root --path=/var/www/wordpress 2>/dev/null"
test_and_report "Admin user exists" "docker exec janet-assistant wp user get admin --allow-root --path=/var/www/wordpress 2>/dev/null"
test_and_report "Janet user exists" "docker exec janet-assistant wp user get janet --allow-root --path=/var/www/wordpress 2>/dev/null"

echo ""
echo "Phase 3: OpenClaw Tests"
echo "-----------------------"

test_and_report "OpenClaw installed" "docker exec janet-assistant which openclaw"
test_and_report "OpenClaw config exists" "docker exec janet-assistant test -f /root/.openclaw/openclaw.json"
test_and_report "OpenClaw running" "docker exec janet-assistant pgrep -f openclaw"

echo ""
echo "Phase 4: Agent Skills Tests"
echo "---------------------------"

test_and_report "Skills directory exists" "docker exec janet-assistant test -d /root/.openclaw/skills"
test_and_report "Janet WordPress skill exists" "docker exec janet-assistant test -f /root/.openclaw/skills/janet-wordpress.md"

echo ""
echo "Phase 5: Integration Tests"
echo "--------------------------"

test_and_report "Node.js installed" "docker exec janet-assistant which node"
test_and_report "npm packages installed" "docker exec janet-assistant test -d /opt/janet/node_modules"
test_and_report "Configuration directory accessible" "docker exec janet-assistant test -d /opt/janet/config"

echo ""
echo "Phase 6: Environment Tests"
echo "--------------------------"

if docker exec janet-assistant test -f /opt/janet/.env; then
    echo -e "${YELLOW}⚠️  WARNING: .env file found in container${NC}"
    echo "   (This is expected if you mounted it as a volume)"
fi

test_and_report "Anthropic API key set" "docker exec janet-assistant bash -c 'test -n \"\$ANTHROPIC_API_KEY\"'"
test_and_report "WordPress DB configured" "docker exec janet-assistant bash -c 'test -n \"\$WORDPRESS_DB_HOST\"'"

echo ""
echo "================================================"
echo "                 Test Summary"
echo "================================================"
echo -e "Tests Passed: ${GREEN}$PASSED${NC}"
echo -e "Tests Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Janet is ready to use.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Setup WhatsApp: docker exec -it janet-assistant ./setup-whatsapp.sh"
    echo "2. Access WordPress: http://localhost:8080"
    echo "3. View logs: docker-compose logs -f"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please review the errors above.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check logs: docker-compose logs"
    echo "2. Verify .env configuration"
    echo "3. Ensure all prerequisites are met"
    echo "4. See TESTING.md for detailed troubleshooting"
    exit 1
fi
