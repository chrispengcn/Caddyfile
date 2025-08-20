```markdown
# Caddy Reverse Proxy Configuration

This Caddyfile configures a reverse proxy for multiple domains with HTTPS, security enhancements, and error handling. Below is an overview of the setup.

## 🚀 Features
- **HTTPS Termination**: Automatic TLS certificates via Let's Encrypt
- **HTTP → HTTPS Redirect**: All HTTP traffic is permanently redirected to HTTPS
- **Reverse Proxy**: Routes traffic to backend service at `http://172.18.0.1:8080`
- **WebSocket Support**: Special handling for WebSocket connections
- **Security Headers**: Enhanced security with strict HTTP headers
- **Error Handling**: Custom responses for 404 and other errors
- **Compression**: Gzip and Zstandard compression for improved performance

## 📝 Domains Served
```
hearingaid.shopym.com
medicalequipment.com.cn
www.medicalequipment.com.cn
```

## ⚙️ Configuration Breakdown

### 1. HTTPS Setup
```caddy
tls your-email@example.com  # Replace with your actual email
```
- Automatically provisions and renews TLS certificates
- Certificate notifications sent to specified email

### 2. Backend Proxy
```caddy
reverse_proxy http://172.18.0.1:8080
```
- All traffic forwarded to backend service at `172.18.0.1:8080`
- WebSocket connections automatically detected and upgraded:
  ```caddy
  @ws {
      header Connection Upgrade
      header Upgrade websocket
  }
  reverse_proxy @ws http://172.18.0.1:8080
  ```

### 3. Security Headers
```caddy
header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    X-XSS-Protection "1; mode=block"
}
```
- Enforces HTTPS for 1 year with HSTS
- Prevents MIME sniffing
- Blocks clickjacking attempts
- Enables XSS protection

### 4. Error Handling
```caddy
handle_errors {
    @404 { expression int({http.error.status_code}) == 404 }
    respond @404 "页面未找到（404 Error）"
    respond "服务器错误: {http.error.status_code}"
}
```
- Custom 404 error message in Chinese
- Generic error message for other status codes

### 5. Performance Optimization
```caddy
encode gzip zstd
```
- Enables Gzip and Zstandard compression
- Reduces bandwidth usage and improves load times

### 6. HTTP Redirection
```caddy
:80 {
    redir https://{host}{uri} permanent
}
```
- Permanent redirect (301) from HTTP to HTTPS
- Handles all domains and paths dynamically

## 🛠️ Setup Instructions

1. **Replace critical values**:
   - Update email in `tls your-email@example.com`
   - Verify backend IP/port matches your service (`172.18.0.1:8080`)

2. **Deploy configuration**:
   ```bash
   caddy run --config ./Caddyfile
   ```

3. **Verify DNS**:
   - Ensure all domains point to this server's IP
   - Include both `example.com` and `www.example.com` variants

## ℹ️ Notes
- First certificate request may take 1-2 minutes
- Backend service must be running before starting Caddy
- WebSocket support requires no additional client configuration
- Compression automatically negotiates best algorithm with clients
``` 

This README explains the configuration's purpose, features, and setup requirements while providing context for each section of the Caddyfile. The markdown format makes it easy to maintain and read in version control systems.
