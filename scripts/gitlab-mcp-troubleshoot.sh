#!/bin/bash
# gitlab-mcp-troubleshoot.sh
# A troubleshooting script for GitLab MCP Server

set -e

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MCP_HOME="${HOME}/.mcp"
LOG_DIR="${MCP_HOME}/logs"
CONFIG_DIR="${MCP_HOME}/config"
PORT=3000
SERVER_PACKAGE="@modelcontextprotocol/git-server"

# Banner
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  GitLab MCP Server Diagnostics ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check environment variables
check_environment() {
  echo -e "${BLUE}Checking environment...${NC}"
  
  # Check Node.js
  if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "✅ Node.js installed: ${NODE_VERSION}"
  else
    echo -e "${RED}❌ Node.js not found. Please install Node.js LTS.${NC}"
    exit 1
  fi
  
  # Check npm
  if command_exists npm; then
    NPM_VERSION=$(npm -v)
    echo -e "✅ npm installed: ${NPM_VERSION}"
  else
    echo -e "${RED}❌ npm not found. Please install npm.${NC}"
    exit 1
  fi
  
  # Check GitLab token
  if [ -n "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
    echo -e "✅ GITLAB_PERSONAL_ACCESS_TOKEN is set"
  else
    echo -e "${YELLOW}⚠️ GITLAB_PERSONAL_ACCESS_TOKEN not set.${NC}"
    echo -e "   Export token with: export GITLAB_PERSONAL_ACCESS_TOKEN=your_token"
  fi
  
  # Check if wrong token variable is set
  if [ -n "$GITLAB_ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ GITLAB_ACCESS_TOKEN is set but should be GITLAB_PERSONAL_ACCESS_TOKEN.${NC}"
    echo -e "   Please unset GITLAB_ACCESS_TOKEN and use GITLAB_PERSONAL_ACCESS_TOKEN instead."
  fi
  
  echo ""
}

# Function to check MCP directory structure
check_directories() {
  echo -e "${BLUE}Checking directory structure...${NC}"
  
  # Check MCP home directory
  if [ -d "$MCP_HOME" ]; then
    echo -e "✅ MCP home directory exists: ${MCP_HOME}"
  else
    echo -e "${YELLOW}⚠️ MCP home directory doesn't exist. Creating...${NC}"
    mkdir -p "$MCP_HOME"
  fi
  
  # Check log directory
  if [ -d "$LOG_DIR" ]; then
    echo -e "✅ Log directory exists: ${LOG_DIR}"
  else
    echo -e "${YELLOW}⚠️ Log directory doesn't exist. Creating...${NC}"
    mkdir -p "$LOG_DIR"
  fi
  
  # Check config directory
  if [ -d "$CONFIG_DIR" ]; then
    echo -e "✅ Config directory exists: ${CONFIG_DIR}"
  else
    echo -e "${YELLOW}⚠️ Config directory doesn't exist. Creating...${NC}"
    mkdir -p "$CONFIG_DIR"
  fi
  
  echo ""
}

# Function to check for port conflicts
check_port_conflicts() {
  echo -e "${BLUE}Checking for port conflicts...${NC}"
  
  # Check if port is in use
  if command_exists lsof; then
    PORT_PROCESS=$(lsof -i:"$PORT" -t 2>/dev/null)
    if [ -n "$PORT_PROCESS" ]; then
      PROCESS_NAME=$(ps -p "$PORT_PROCESS" -o comm=)
      echo -e "${RED}❌ Port ${PORT} is already in use by process ${PORT_PROCESS} (${PROCESS_NAME})${NC}"
      
      # Check if it's Claude
      if [[ "$PROCESS_NAME" == *"Claude"* ]]; then
        echo -e "${YELLOW}⚠️ Claude desktop appears to be running and using this port.${NC}"
        echo -e "   Consider changing the port in your config or closing Claude desktop."
      fi
    else
      echo -e "✅ Port ${PORT} is available"
    fi
  else
    echo -e "${YELLOW}⚠️ 'lsof' command not found. Cannot check port availability.${NC}"
  fi
  
  echo ""
}

# Function to check for stale lock files
check_lock_files() {
  echo -e "${BLUE}Checking for stale lock files...${NC}"
  
  LOCK_FILE="${MCP_HOME}/server.lock"
  if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(($(date +%s) - $(date -r "$LOCK_FILE" +%s)))
    if [ $LOCK_AGE -gt 3600 ]; then
      echo -e "${YELLOW}⚠️ Found stale lock file: ${LOCK_FILE} (${LOCK_AGE} seconds old)${NC}"
      read -p "   Remove stale lock file? (y/n): " REMOVE_LOCK
      if [[ "$REMOVE_LOCK" == "y" ]]; then
        rm "$LOCK_FILE"
        echo -e "   Lock file removed."
      fi
    else
      echo -e "${RED}❌ Active lock file found: ${LOCK_FILE}${NC}"
      echo -e "   This suggests another instance may be running."
    fi
  else
    echo -e "✅ No lock files found"
  fi
  
  echo ""
}

# Main execution
main() {
  check_environment
  check_directories
  check_port_conflicts
  check_lock_files
  
  echo -e "${GREEN}Troubleshooting complete!${NC}"
  echo -e "${BLUE}================================${NC}"
}

# Run the script
main
