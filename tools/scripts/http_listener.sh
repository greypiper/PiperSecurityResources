#!/bin/bash

LOG_FILE="http_requests.log"

# Ensure the log file exists or create a new one
touch $LOG_FILE

# Function to log incoming requests
log_request() {
    timestamp=$(date +"%Y-%m-%d %T")
    echo -e "[$timestamp] Request received:\n$1\n------------------------\n" >> $LOG_FILE
}

# Start an infinite loop to listen for incoming requests
while true; do
    # Use a subshell to handle each connection separately
    (
        # Listen on port 8080 and log incoming data
        request=$(cat)
        echo -e "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
        log_request "$request"
    ) | nc -l -p 8080 -q 1
done
