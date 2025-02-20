// gitlab-adapter.js
// Basic adapter for translating GitHub API calls to GitLab API format

const axios = require('axios');
const path = require('path');
const fs = require('fs');
const os = require('os');

class GitLabAdapter {
  constructor(config = {}) {
    this.config = config;
    this.token = process.env.GITLAB_PERSONAL_ACCESS_TOKEN;
    
    if (!this.token) {
      console.error('GITLAB_PERSONAL_ACCESS_TOKEN environment variable not set');
      throw new Error('GitLab token not configured');
    }
    
    this.baseUrl = config.baseUrl || 'https://gitlab.com/api/v4';
    this.logPath = config.logPath || path.join(os.homedir(), '.mcp', 'logs', 'gitlab-adapter.log');
    
    // Ensure log directory exists
    const logDir = path.dirname(this.logPath);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    
    // Set up axios instance with authentication
    this.client = axios.create({
      baseURL: this.baseUrl,
      headers: {
        'Private-Token': this.token,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('GitLab adapter initialized');
  }
  
  // Transform GitHub parameters to GitLab format
  transformParams(params, operation) {
    console.log(`Transforming params for operation: ${operation}`);
    const transformed = {...params};
    
    switch (operation) {
      case 'get_file_contents':
        // GitLab uses 'ref' instead of 'branch'
        if (params.branch) {
          transformed.ref = params.branch;
          delete transformed.branch;
        }
        break;
        
      case 'create_repository':
        // GitLab uses 'name' and 'path' 
        transformed.name = params.name;
        transformed.path = params.name.toLowerCase().replace(/\s+/g, '-');
        // GitLab uses 'visibility' instead of 'private'
        transformed.visibility = params.private ? 'private' : 'public';
        if (params.description) transformed.description = params.description;
        if (params.autoInit) transformed.initialize_with_readme = params.autoInit;
        delete transformed.private;
        delete transformed.autoInit;
        break;
        
      case 'create_or_update_file':
        // GitLab requires different parameter names
        transformed.branch = params.branch;
        transformed.content = Buffer.from(params.content).toString('base64');
        transformed.commit_message = params.message;
        // If updating existing file
        if (params.sha) transformed.last_commit_id = params.sha;
        break;
    }
    
    return transformed;
  }
  
  // Get the appropriate GitLab endpoint for each operation
  getEndpoint(operation, params) {
    switch (operation) {
      case 'get_file_contents':
        return `/projects/${encodeURIComponent(params.owner + '/' + params.repo)}/repository/files/${encodeURIComponent(params.path)}`;
        
      case 'create_repository':
        return '/projects';
        
      case 'create_or_update_file':
        return `/projects/${encodeURIComponent(params.owner + '/' + params.repo)}/repository/files/${encodeURIComponent(params.path)}`;
        
      default:
        throw new Error(`Unsupported operation: ${operation}`);
    }
  }
}

module.exports = GitLabAdapter;