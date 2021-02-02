
These scripts were developed in response to the requirement to contact remote endpoints / users with advisory or warning messages.

The Toast Endpoint Script, once deployed runs in the background after system startup. This is the server side of the application. The simple TCP server receives messages
and converts the binary data to a string presented in an XML Toast Message. An embedded icon set allows for custom message formats.

The client script is a graphical front end for a TCP client messaging system. The client has the ability to send a message to a single user or to an entire Organizational Unit.

These scripts can be run as is or in their binary format. For ease of use and demonstration, the binaries are recommended.

Instructions for use:

-> Navigate to the 'DeployToast' directory \n
-> Navigate to the 'Binaries' directory
-> Navigate to the most recent version
-> Run 'DeployEndpointToast.exe'
   -> This script will embed the server side binary in: C:\Public\Documents\ directory
   -> The script also creates a firewall rule and sets the endpoint server script to run on startup
-> To send a message to an endpoint, run the ToastMessengerClient.exe

To remove the endpoint script and all log files:

-> Run CleanupToast.exe
