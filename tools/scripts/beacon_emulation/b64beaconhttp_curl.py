import socket
import time
import random
import argparse
import base64
import subprocess
import urllib.parse

parser = argparse.ArgumentParser(description="Example command: 'python3 .\\beacon-simulator.py -ip 192.168.0.5 -p 2000 -i 10 -j 3 -m 1024' or 'python3 .\\beacon-simulator.py -ip 192.168.0.5 -p 2000 --interval 120 --jitter 12 --max_payload 1024 --tcp'")
parser.add_argument("-ip", dest="ip", type=str, help="Use -ip to set your target IP address.", required=True)
parser.add_argument("-p", "--port", type=int, dest="port", help="Use -p to specify a port for use.", required=True)
parser.add_argument("-i", "--interval", type=int, dest="interval", help="Use -i to specify an interval for the beacon in seconds.", required=True)
parser.add_argument("-j", "--jitter", type=int, dest="jitter", help="Use -j to specify the amount of jitter to be used in seconds.", required=True)
parser.add_argument("--tcp", dest="tcp", action="store_true", help="Use -t to select the tcp protocol. This is optional and TCP is default.", required=False)
parser.add_argument("--udp", dest="udp", action="store_true", help="Use -u to select the udp protocol. This is optional and TCP is default.", required=False)
parser.add_argument("-m", "--max_payload", type=int, dest="max_payload", help="Use -m to set a maximum payload size.", required=True)
args = parser.parse_args()

server_ip = args.ip
server_port = args.port
max_size = args.max_payload
data = "a"
interval = args.interval
variance = args.jitter
jitter = random.randint(interval - variance, interval + variance)

def send_curl_request(url):
    try:
        # Add the Firefox User-Agent to the curl command
        subprocess.run(['curl', '-X', 'GET', '-H', 'Connection: close', '-H', 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0', '--max-time', '5', url], check=True, timeout=10)
    except subprocess.CalledProcessError as e:
        print(f"Error sending request: {e}")
    except subprocess.TimeoutExpired:
        print("Curl request timed out.")

def tcp_beacon():
    count = 0
    while True:
        message_size = random.randint(0, max_size)
        message = "".join([data] * message_size)

        # Encode the message with base64
        encoded_message = base64.b64encode(message.encode('utf-8')).decode('utf-8')

        # Build an HTTP request with the encoded data in the query parameters
        url = f"http://{server_ip}:{server_port}/test?data={urllib.parse.quote(encoded_message)}"

        jitter = random.randint(interval - variance, interval + variance)
        print("Amount of jitter:", jitter)
        print("HTTP Request sent:", url)

        # Use curl to send the HTTP request
        send_curl_request(url)

        count += 1
        print("Number of beacons sent:", count)
        time.sleep(jitter)

def udp_beacon():
    count = 0
    while True:
        message_size = random.randint(0, max_size)
        message = "".join([data] * message_size)
        message = bytes(message, 'utf-8')
        jitter = random.randint(interval - variance, interval + variance)
        print("Amount of jitter: ", jitter)
        print("Data sent: ", message)

        # Use curl to send the UDP request
        url = f"http://{server_ip}:{server_port}"
        send_curl_request(url)

        count += 1
        print("Number of beacons sent: ", count)
        time.sleep(jitter)

if args.tcp:
    tcp_beacon()
elif args.udp:
    udp_beacon()
else:
    tcp_beacon()
