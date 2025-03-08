# Update the system
sudo dnf update -y

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull model
sudo ollama pull tinyllama

# Configure Ollama to accept requests from any origin
# TODO more granular origins
sudo mkdir /etc/systemd/system/ollama.service.d
sudo touch /etc/systemd/system/ollama.service.d/override.conf
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="OLLAMA_ORIGINS=*"
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF

# Install Nginx
sudo dnf install -y nginx

# Configure Nginx
# TODO: This is not a real Bearer token
sudo touch /etc/nginx/conf.d/ollama.conf
sudo tee /etc/nginx/conf.d/ollama.conf > /dev/null <<EOF
server {
    listen 80;
    listen 443;

    location / {
        # Require the API key in the "Authorization" header
        if (\$http_authorization != "Bearer ${OLLAMA_API_KEY}") {
            return 403 "Forbidden";
        }

        proxy_pass http://127.0.0.1:11434;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Reload daemon overrides
sudo systemctl daemon-reload

# Start Ollama server
sudo systemctl start ollama
sudo systemctl enable ollama

# Update Nginx configuration with the API key
sudo systemctl start nginx
sudo systemctl enable nginx
