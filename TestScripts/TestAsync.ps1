# Does a TCP connection on specified port (135 by default)

#$ErrorActionPreference = "SilentlyContinue"

# Create TCP Client
$tcpclient = new-Object system.Net.Sockets.TcpClient

# Tell TCP Client to connect to machine on Port
$iar = $tcpclient.BeginConnect('10.150.254.104',3247,$null,$null)

# Set the wait time
$wait = $iar.AsyncWaitHandle.WaitOne(500,$false)

# Check to see if the connection is done
if(!$wait)
{
    # Close the connection and report timeout
    $tcpclient.Close()
    if($verbose){Write-Host "Connection Timeout"}
    Return $false
}
else
{

    # Close the connection and report the error if there is one
    $error.Clear()
    $tcpclient.EndConnect($iar) | out-Null
    if(!$?){if($verbose){write-host $error[0]};$failed = $true}
    $tcpclient.Close()
}