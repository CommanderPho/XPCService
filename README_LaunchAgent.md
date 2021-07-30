#  Launch Agent and system-level services

See https://rderik.com/blog/creating-a-launch-agent-that-provides-an-xpc-service-on-macos/


The goal is to create a service that can be accessed by other processes. To do this, we'll need to create an agent that provides an XPC service.




Daemons and agents run on-demand. This means that we load the configuration to launchd then the Launch Daemon will be listening for any request to the registered daemons and agents, and spawn them when needed. It will also shut down daemons and agents if they are no longer required.




need a plist file in ~/Library/LaunchAgents/ to register our agent. 

Create a new file inside ~/Library/LaunchAgents/ named com.rderik.rdconsolesequencerxpc.plist with the following content:

com.PhoHale.

