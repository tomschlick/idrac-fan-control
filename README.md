# iDRAC Fan Control
This is a Docker container that uses IPMI to monitor and control the fans on a Dell server through the iDRAC using raw commands.  

This script will read the ambient temp sensor every X seconds (20 by default) and then apply a custom defined fan speed to the iDRAC. It has normal, Med, High and Emergency states (all user configurable). Each state can have a custom fan speed but the Emergency state sets it back to Auto-control from the BIOS/iDRAC.  


### Server Details
```
IPMIHOST=<IP Address of the iDRAC on the Server>
IPMIUSER=<User for the iDRAC>
IPMIPW=<Password for the iDRAC
```
