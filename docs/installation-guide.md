# GitLab MCP Server Installation Guide

This guide helps you install and configure the Git MCP server to work with GitLab.

## Prerequisites

- Node.js (LTS version recommended)
- npm or yarn
- GitLab account with personal access token
- Basic understanding of MCP servers

## Installation Steps

1. **Install the Git MCP Server**

   ```bash
   # Option 1: Install globally (recommended for stability)
   npm install -g @modelcontextprotocol/git-server

   # Option 2: Run without installing
   npx @modelcontextprotocol/git-server
   ```

   > ⚠️ **Important**: Do NOT use `uvx` as it caused installation issues in previous attempts.

2. **Set up environment variables**

   Create a `.env` file in your project directory:

   ```
   # For GitLab - use the correct variable name!
   GITLAB_PERSONAL_ACCESS_TOKEN=your_gitlab_token_here

   # Optional configuration
   MCP_SERVER_PORT=3000
   MCP_LOG_LEVEL=info
   ```

   > ⚠️ **Important**: The environment variable must be `GITLAB_PERSONAL_ACCESS_TOKEN`, not `GITLAB_ACCESS_TOKEN`.

3. **Create configuration directories**

   ```bash
   mkdir -p ~/.mcp/config
   mkdir -p ~/.mcp/logs
   mkdir -p ~/.mcp/adapters
   ```

4. **Install the GitLab adapter**

   Copy the GitLab adapter from this repository to your adapters directory:

   ```bash
   cp src/gitlab-adapter.js ~/.mcp/adapters/
   ```

5. **Create a configuration file**

   Create `~/.mcp/config/config.json` with the following content:

   ```json
   {
     "server": {
       "port": 3000,
       "logLevel": "info",
       "logFile": "~/.mcp/logs/server.log"
     },
     "gitlab": {
       "useAdapter": true,
       "adapterPath": "~/.mcp/adapters/gitlab-adapter.js"
     },
     "process": {
       "cleanupOnExit": true,
       "timeoutMs": 30000
     }
   }
   ```

## Starting the Server

Create a startup script called `start-gitlab-mcp.sh`:

```bash
#!/bin/bash

# Check if Claude desktop is running
if pgrep -f "Claude" > /dev/null; then
  echo "Warning: Claude desktop is running, which may cause port conflicts"
  read -p "Continue anyway? (y/n) " choice
  if [[ $choice != "y" ]]; then
    exit 1
  fi
fi

# Set environment variables
export GITLAB_PERSONAL_ACCESS_TOKEN="your_token_here"
export MCP_SERVER_PORT=3000
export MCP_CONFIG_PATH="$HOME/.mcp/config/config.json"

# Run the server
npx @modelcontextprotocol/git-server
```

Make it executable and run it:

```bash
chmod +x start-gitlab-mcp.sh
./start-gitlab-mcp.sh
```

## Verifying Installation

Once the server is running, you can test it with:

```bash
curl http://localhost:3000/status
```

You should see a response indicating the server is running and connected to GitLab.

## Troubleshooting

If you encounter issues, refer to the [Troubleshooting Guide](troubleshooting-guide.md) for common problems and solutions.
