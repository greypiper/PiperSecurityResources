param(
    [string]$ip,
    [int]$port,
    [int]$interval,
    [int]$jitter,
    [switch]$tcp,
    [switch]$udp,
    [int]$max_payload
)

$data = "a"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Send-HttpRequest {
    param (
        [string]$url
    )

    try {
        # Add the Firefox User-Agent to the headers
        $headers = @{
            'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0'
        }

        # Set the timeout for connection wait
        $timeout = 10

        # Send HTTP request using Invoke-RestMethod with timeout
        Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec $timeout
    } catch {
        Write-Host "Error sending request: $_"
    }
}

function Get-Jitter {
    param (
        [int]$baseValue,
        [int]$variance
    )

    $jitter = Get-Random -Minimum 0 -Maximum ($variance * 2 + 1)
    return [math]::Max($baseValue - $variance + $jitter, 0)
}

function Tcp-Beacon {
    $count = 0
    while ($true) {
        $messageSize = Get-Random -Minimum 0 -Maximum $max_payload
        $message = -join ($data * $messageSize)

        # Encode the message with base64
        $encodedMessage = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($message))

        # Build an HTTP request with the encoded data in the query parameters
        $url = "http://$ip`:$port/test?data=$([System.Web.HttpUtility]::UrlEncode($encodedMessage))"

        $jitter = Get-Jitter -baseValue $interval -variance $jitter
        Write-Host "Amount of jitter: $jitter"
        Write-Host "HTTP Request sent: $url"

        # Use Invoke-RestMethod to send the HTTP request with timeout
        Send-HttpRequest $url

        $count++
        Write-Host "Number of beacons sent: $count"
        Start-Sleep -Seconds $jitter
    }
}

function Udp-Beacon {
    $count = 0
    while ($true) {
        $messageSize = Get-Random -Minimum 0 -Maximum $max_payload
        $message = -join ($data * $messageSize)

        $jitter = Get-Jitter -baseValue $interval -variance $jitter
        Write-Host "Amount of jitter: $jitter"
        Write-Host "Data sent: $message"

        # Use Invoke-RestMethod to send the UDP request with timeout
        $url = "http://$ip`:$port"
        Send-HttpRequest $url

        $count++
        Write-Host "Number of beacons sent: $count"
        Start-Sleep -Seconds $jitter
    }
}

if ($tcp) {
    Tcp-Beacon
} elseif ($udp) {
    Udp-Beacon
} else {
    Tcp-Beacon
}
