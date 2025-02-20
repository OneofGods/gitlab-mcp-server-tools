# GitLab MCP Server Tools

Configuration, adapters, and troubleshooting tools for GitLab MCP server implementation based on the Git MCP server.

## Overview

This repository contains resources to help adapt the Git MCP server to work with GitLab, addressing common issues encountered during implementation.

## Repository Structure

- **`/docs`**: Documentation and guides
  - [Troubleshooting Guide](docs/troubleshooting-guide.md): Solutions for common issues

- **`/scripts`**: Utility scripts
  - [Simple Test Script](scripts/simple-script.js): Basic test script

## Key Features

- GitLab adapter for parameter translation
- Process management improvements
- Lock file handling
- Port conflict resolution
- Detailed troubleshooting steps

## Background

This project addresses common issues encountered when adapting MCP servers to work with GitLab:

1. Environment variable naming issues (GITLAB_PERSONAL_ACCESS_TOKEN vs GITLAB_ACCESS_TOKEN)
2. API parameter format mismatches between GitHub and GitLab
3. Process management and lock file issues
4. Port conflicts with Claude desktop

## Getting Started

See the documentation in the `/docs` directory for detailed setup instructions.

## License

MIT
