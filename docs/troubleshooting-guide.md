# GitLab MCP Server Troubleshooting Guide

This guide provides solutions for common issues encountered when working with GitLab MCP Server.

## Common Issues

### Environment Variable Problems

**Issue**: Server fails to authenticate with GitLab
**Solution**: Ensure you're using `GITLAB_PERSONAL_ACCESS_TOKEN` and not `GITLAB_ACCESS_TOKEN`

### Port Conflicts

**Issue**: Server fails to start due to port conflicts
**Solution**: 
- Change the port in config.json
- Check if Claude desktop is running on the same port
- Use the troubleshooting script to detect conflicts

### Process Management

**Issue**: Stale lock files prevent server from starting
**Solution**: Use the lock handler to properly manage process locks
