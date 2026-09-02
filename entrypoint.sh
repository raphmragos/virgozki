#!/bin/sh
set -e

echo "🚀 Starting Xray Core..."
xray run -c /etc/xray.json &
XRAY_PID=$!

# Hintayin natin na ready na ang Xray bago simulan ang Nginx
sleep 3
if ! kill -0 $XRAY_PID 2>/dev/null; then
    echo "❌ FAILED: Xray did not start! Exiting..."
    exit 1
fi
echo "✅ Xray running (PID: $XRAY_PID)"

echo "🌐 Starting OpenResty/Nginx..."
exec openresty -g 'daemon off;'
