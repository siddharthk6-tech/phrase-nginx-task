#!/bin/bash
set -e
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

mkdir -p /home/ec2-user/nginx
cat > /home/ec2-user/nginx/default.conf <<'EOF'
server {
  listen 80;
  server_name _;

  location / {
    root /usr/share/nginx/html;
    index index.html;
  }

  location /phrase {
    add_header Content-Type text/plain;
    return 200 'OK';
  }
}
EOF

cat > /home/ec2-user/nginx/index.html <<'EOF'
<html><body><h1>NGINX on $(hostname)</h1></body></html>
EOF

cat > /home/ec2-user/nginx/Dockerfile <<'EOF'
FROM nginx:stable
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
EOF

cd /home/ec2-user/nginx
docker build -t nginx-phrase .
docker run -d --name nginx -p 80:80 --restart unless-stopped nginx-phrase

