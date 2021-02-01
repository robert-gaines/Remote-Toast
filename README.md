
These scripts were developed in response to the requirement to contact remote endpoints / users with advisory or warning messages.

The Toast Endpoint Script, once deployed runs in the background after system startup. This is the server side of the application. The simple TCP server receives messages
and converts the binary data to a string presented in an XML Toast Message. An embedded icon set allows for custom message formats.

The client script is a graphical front end for a TCP client messaging system. The client has the ability to send a message to a single user or to an entire Organizational Unit.
