
These scripts were developed in response to the requirement to contact remote endpoints / users with advisory or warning messages.
<br>
The Toast Endpoint Script, once deployed runs in the background after system startup. This is the server side of the application. The simple TCP server receives messages
and converts the binary data to a string presented in an XML Toast Message. An embedded icon set allows for custom message formats.
<br>
The client script is a graphical front end for a TCP client messaging system. The client has the ability to send a message to a single user or to an entire Organizational Unit.
<br>
These scripts can be run as is or in their binary format. For ease of use and demonstration, the binaries are recommended.
<br>
Instructions for use:
<br>
-> Navigate to the 'DeployToast' directory <br>
-> Navigate to the 'Binaries' directory <br>
-> Navigate to the most recent version <br>
-> Run 'DeployEndpointToast.exe' <br>
   -> This script will embed the server side binary in: C:\Public\Documents\ directory <br>
   -> The script also creates a firewall rule and sets the endpoint server script to run on startup <br>
-> To send a message to an endpoint, run the ToastMessengerClient.exe <br>
<br>
To remove the endpoint script and all log files: <br>
<br>
-> Run CleanupToast.exe <br>
