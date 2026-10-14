#!/bin/bash
set -e

echo "=== Starting Attest Deployment ==="

APP_DIR="/root/Attest"
if [ ! -d "$APP_DIR" ]; then
  if [ -d "/var/www/Attest" ]; then
    APP_DIR="/var/www/Attest"
  elif [ -d "/root/Email_Hvel" ]; then
    APP_DIR="/root/Email_Hvel"
  fi
fi

if [ -d "$APP_DIR" ]; then
  cd "$APP_DIR"
  echo "Pulling latest changes from git in $APP_DIR..."
  git pull origin main
else
  echo "Application directory not found, using current directory: $(pwd)"
fi

# Deploy backend
if [ -d "hvel-backend" ]; then
  echo "Deploying backend..."
  cd hvel-backend
  npm install --omit=dev || npm install
  if command -v pm2 &> /dev/null; then
    pm2 restart hvel-backend || pm2 start index.js --name hvel-backend
  fi
  cd ..
fi

# Deploy website
if [ -d "hvel-website" ]; then
  echo "Deploying website..."
  cd hvel-website
  npm install
  npm run build
  if command -v pm2 &> /dev/null; then
    pm2 restart hvel-website || pm2 start npm --name hvel-website -- start
  fi
  cd ..
fi

echo "=== Deployment Finished Successfully ==="
