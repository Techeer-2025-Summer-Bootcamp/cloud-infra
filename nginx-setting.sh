#!/bin/bash

# Update package list and install Nginx
sudo apt update
sudo apt install nginx -y

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80;
    server_name cloudsession.cloud;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Additional useful proxy headers
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# If test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "Nginx configuration has been updated and reloaded successfully"
    
    # Test the connection
    echo "Testing local connection..."
    curl -i http://localhost
    
    echo "To test the domain connection, run:"
    echo "curl -i http://cloudsession.cloud"
else
    echo "Nginx configuration test failed. Please check the configuration."
fi

# Make the script executable
chmod +x nginx-setting.sh 