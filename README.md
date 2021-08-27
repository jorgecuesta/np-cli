### Node Pilot CLI

This project is just an external tool for [Node Pilot]() that allow user to setup it as service using systemd.
This will allow your system start Node Pilot after a reboot and after docker service is up and running.
With this you can also check service status, disable, start, stop, restart and even uninstall service.

### Usage
1. Clone: `git clone https://github.com/jorgecuesta/np-cli.git && cd np-cli`
2. Grant Execution: `chown +x np_cli.sh`
3. Use:
   1. Install Service: `./np_cli.sh install [-p <abs_path_to_np>] [-u <username_to_run_np>]` -p and -u are optionals. -p will look np at home of current user. -u will take current session user.
   2. Uninstall Service: `./np_cli.sh uninstall` 
   3. Start Service: `./np_cli.sh start` 
   4. Stop Service: `./np_cli.sh stop` 
   5. Restart Service: `./np_cli.sh restart` 
   6. Status Service: `./np_cli.sh status` 
   7. Disable Service (disable auto start on reboot): `./np_cli.sh disable` 
   8. Enable Service: (enable auto start on reboot)`./np_cli.sh enable` 
   