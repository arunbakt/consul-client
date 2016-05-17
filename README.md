# consul-client

A consul image that is created to be run as a client. It comes with couple of bash scripts that provide the following functions:
1. Handle a service registration and deregistration by keeping an entry on these service registration events locally
2. Launch and maintain consul watch commands on service registration and deregistrations. This consul watch is to catch all key value update events and apply these updates to the respective services by using their http apis.