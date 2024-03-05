#!/bin/bash

# Ensure the script is run with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Step 1: Update the operating system packages
apt update -y

# Step 2: Install Nginx
apt install nginx -y

# Step 3: Navigate to /var/www and create a folder named your_domain.com
cd /var/www
mkdir mystic.com
cd mystic.com

# Step 4: Clone the GitHub repository into the directory
# Replace 'https://github.com/siddhantbhattarai/e-commerce-static-site.git' with your actual GitHub repository URL
git clone https://github.com/siddhantbhattarai/e-commerce-static-site.git .

# Ensure git is installed or handle its absence
if ! command -v git &> /dev/null
then
    echo "git could not be found, installing now..."
    apt install git -y
    git clone https://github.com/siddhantbhattarai/e-commerce-static-site.git .
fi

# Step 5: Configure Nginx to serve your site
# Navigate to Nginx sites-available directory and create a new configuration
cd /etc/nginx/sites-available/

# Note: It's better to use the sites-available and sites-enabled pattern with symlinks
# Replace 'mystic.com' with the actual domain name file for clarity, e.g., your_domain.com
sudo tee mystic.com <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name mystic.com;

    root /var/www/mystic.com;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Create a symlink to enable the site
ln -s /etc/nginx/sites-available/mystic.com /etc/nginx/sites-enabled/

# Optional: Remove the default Nginx site configuration to avoid conflicts
rm /etc/nginx/sites-enabled/default

# Step 7: Test Nginx configuration for syntax errors
nginx -t

# Step 8: Restart Nginx to apply the changes
systemctl restart nginx

# Display a success message
echo "Nginx has been configured to serve your site and restarted successfully!"
