#install node || npm 
sudo yum update
sudo yum install epel-release
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install nodejs
node -v
npm -v

# install php 8.1
# Update the system
sudo yum update -y

# Install the EPEL repository
sudo yum install -y epel-release

# Install the Remi repository
sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# Enable the Remi repository for PHP 8.1
sudo yum-config-manager --enable remi-php81

# Install PHP 8.1 along with required extensions
sudo yum install -y php php-cli php-common php-mysqlnd php-json php-opcache php-mbstring php-xml php-gd php-curl

# Verify the PHP installation
php -v

echo "PHP 8.1 is now installed."

# Replace these with your actual domain names and email address
SUBDOMAIN1="sub1.example.com"
SUBDOMAIN2="sub2.example.com"
EMAIL="your-email@example.com"

# Install Nginx
sudo yum install -y nginx

# Start and enable Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Create the configuration files for subdomains
sudo tee "/etc/nginx/conf.d/${SUBDOMAIN1}.conf" > /dev/null <<EOL
server {
    listen 80;
    server_name ${SUBDOMAIN1};

    location / {
        root /var/www/${SUBDOMAIN1};
        index index.php index.html;
    }

    location ~ /.well-known/acme-challenge {
        allow all;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

sudo tee "/etc/nginx/conf.d/${SUBDOMAIN2}.conf" > /dev/null <<EOL
server {
    listen 80;
    server_name ${SUBDOMAIN2};

    location / {
        root /var/www/${SUBDOMAIN2};
        index index.php index.html;
    }

    location ~ /.well-known/acme-challenge {
        allow all;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

# Create the root directories for subdomains
sudo mkdir -p "/var/www/${SUBDOMAIN1}"
sudo mkdir -p "/var/www/${SUBDOMAIN2}"

# Add content to the subdomain root directories (index.php files)
echo "<?php echo 'Welcome to ${SUBDOMAIN1}'; ?>" | sudo tee "/var/www/${SUBDOMAIN1}/index.php" > /dev/null
echo "<?php echo 'Welcome to ${SUBDOMAIN2}'; ?>" | sudo tee "/var/www/${SUBDOMAIN2}/index.php" > /dev/null

# Install Certbot for Let's Encrypt
sudo yum install -y certbot python3-certbot-nginx

# Allow HTTP and HTTPS traffic in the firewall
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# Request SSL certificates for the subdomains
sudo certbot --nginx -d ${SUBDOMAIN1} -d ${SUBDOMAIN2} --non-interactive --agree-tos --email ${EMAIL}

# Install PHP 8.1 and PHP-FPM
sudo yum install -y php php-fpm

# Configure PHP-FPM for PHP 8.1
sudo systemctl enable php-fpm
sudo systemctl start php-fpm

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply the changes
sudo systemctl reload nginx

echo "Nginx is installed and configured with SSL and PHP 8.1 for ${SUBDOMAIN1} and ${SUBDOMAIN2}"


