#!/bin/bash
#
# run-emulator-tests.sh
#
# Starts the Firebase Auth + Firestore emulators, runs the integration tests,
# then shuts down the emulators. Exit code reflects test results.
#
# Prerequisites:
#   - Firebase CLI installed (npm install -g firebase-tools or brew install firebase-cli)
#   - Java Runtime (required by Firestore emulator)
#
# Usage:
#   ./scripts/run-emulator-tests.sh
#   ./scripts/run-emulator-tests.sh --simulator "iPhone 16 Pro"
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SIMULATOR_NAME="${1:-iPhone 16}"

cd "$PROJECT_DIR"

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Firebase Emulator Integration Tests ===${NC}"

# Check prerequisites
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Error: Firebase CLI not found. Install with: npm install -g firebase-tools${NC}"
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo -e "${RED}Error: Java Runtime not found. Install with: brew install openjdk${NC}"
    exit 1
fi

# Start emulators in the background
echo -e "${YELLOW}Starting Firebase emulators (Auth:9099, Firestore:8080)...${NC}"
firebase emulators:start --only auth,firestore &
EMULATOR_PID=$!

# Wait for emulators to be ready
echo "Waiting for emulators to start..."
MAX_WAIT=30
WAITED=0
while ! curl -s http://localhost:8080/ > /dev/null 2>&1; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo -e "${RED}Error: Emulators did not start within ${MAX_WAIT}s${NC}"
        kill $EMULATOR_PID 2>/dev/null || true
        exit 1
    fi
done
echo -e "${GREEN}Emulators are ready.${NC}"

# Run integration tests
echo -e "${YELLOW}Running integration tests...${NC}"
TEST_EXIT_CODE=0
xcodebuild test \
    -workspace Somlimee.xcworkspace \
    -scheme Somlimee \
    -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}" \
    -only-testing:SomlimeeTests/FirestoreReadTests \
    -only-testing:SomlimeeTests/FirestoreWriteTests \
    -only-testing:SomlimeeTests/FirestoreRulesTests \
    2>&1 | tail -50 || TEST_EXIT_CODE=$?

# Stop emulators
echo -e "${YELLOW}Stopping emulators...${NC}"
kill $EMULATOR_PID 2>/dev/null || true
wait $EMULATOR_PID 2>/dev/null || true

# Report results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}=== All integration tests passed ===${NC}"
else
    echo -e "${RED}=== Integration tests failed (exit code: $TEST_EXIT_CODE) ===${NC}"
fi

exit $TEST_EXIT_CODE
