#!/bin/bash
set -e

CMD=$1
SERVICE_FILE=/etc/systemd/system/np.service

check_service_exists(){
  echo "Checking if Node Pilot was Installed as Service"
  if ! [[ -f "$SERVICE_FILE" ]]; then
    return 1
  fi

  return 0
}

install(){
  echo "Installing Node Pilot service with systemd"

  if [[ -f "$SERVICE_FILE" ]]; then
    read -p "Node Pilot is already installed as Service. You want to replace it? (Y\n)" -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
      stop
      uninstall
    then
       # handle exits from shell or function but don't exit interactive shell
       [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi
  fi

  while getopts p:u: flag
  do
      case "${flag}" in
          p) NP_FILE=${OPTARG};;
          u) OPT_USER=${OPTARG};;
          *) echo "Usage: $0 [-p <abs_np_path>] [-u <username>]" >&2
               exit 1 ;;
      esac
  done

  if [ -z "$OPT_USER" ]; then
    OPT_USER=$USER
  fi

  if [ -z "$NP_FILE" ]; then
    NP_FILE="/home/$USER/np"
  fi

  if ! [[ -f "$NP_FILE" ]]; then
    echo "$NP_FILE does not exist."
    exit 1
  fi

  echo "User: $OPT_USER"
  echo "Node Pilot File: $NP_FILE"

  echo "Preparing Service to run Node Pilot as current user"
  cp np.service.template np.service

  sed -i "s|User=USER|User=$OPT_USER|" np.service
  sed -i "s|ExecStart=NP_FILE|ExecStart=$NP_FILE|" np.service

  echo "Copy Node Pilot service file"
  sudo cp np.service $SERVICE_FILE
  sudo chmod 640 $SERVICE_FILE

  echo "Reload systemd files"
  sudo systemctl daemon-reload

  enable

  echo "Starting up Node Pilot as Service"
  sudo systemctl start np

  echo "Verify Service"
  sudo systemctl status np.service
}

uninstall(){
  check_service_exists

  stop

  disable

  echo "Removing Node Pilot Service file"
  sudo rm /etc/systemd/system/np.service

  echo "Reload systemd files"
  sudo systemctl daemon-reload
}

start(){
  check_service_exists
  echo "Starting Node Pilot Service"
  sudo systemctl start np
}

stop(){
  check_service_exists
  echo "Stopping Node Pilot Service"
  sudo systemctl stop np
}

restart(){
  check_service_exists
  echo "Restarting Node Pilot Service"
  sudo systemctl restart np
}

status(){
  check_service_exists
  sudo systemctl status np
}

enable(){
  check_service_exists
  echo "Setting up Node Pilot at startup (boot time)"
  sudo systemctl enable np
}

disable(){
  check_service_exists
  echo "Disable Node Pilot Service"
  sudo systemctl disable np.service
}

if [[ $CMD = "start" ]]; then
  start
elif [[ $CMD = "stop" ]]; then
  stop
elif [[ $CMD = "restart" ]]; then
  restart
elif [[ $CMD = "status" ]]; then
  status
elif [[ $CMD = "install" ]]; then
  install
elif [[ $CMD = "uninstall" ]]; then
  uninstall
elif [[ $CMD = "enable" ]]; then
  enable
elif [[ $CMD = "disable" ]]; then
  disable
else
  echo "Available options are: install | uninstall | start | stop | restart | status"
  echo "Install: './np_cli.sh install [-p <np-path>] [-u <script user>]'"
  echo "Defaults:"
  echo "  -u whoami"
  echo "  -p ~/np "
fi

exit 0
