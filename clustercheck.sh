#!/usr/bin/env bash
#
# Check node status (for F5, HAproxy)
#

ERR_LOG='/dev/null'
DISABLE_FILE='/var/tmp/node.disable'

main() {
  # Examles:
  # Check process is running (by name)
  # out="$(ps aux | grep nginx | grep -v grep | wc -l)"
  # check_equals "$out" "0" "Nginx server is down"
  # echo $out
  #
  # Check if socket 3000 is open (Centos 7):
  # out="$(/usr/sbin/ss -ltn 2>$ERR_LOG | grep 3000 | awk '{print $1}')"
  # check_not_equals "$out" "" "Socket 3000 is closed"
  #
  # Check if socket 3000 is open: legacy
  # out="$(netstat -na 2>$ERR_LOG | grep 3000 | awk '{print $6}')"
  # check_not_equals "$out" "" "Socket 3000 is closed"
  #
  # Check remote mysql server
  # out="$(mysqladmin --connect-timeout=1 ping 2>$ERR_LOG)"
  # check_equals "$out" "mysqld is alive" "Mysql server not responding"

  success
}

fail() {
  local msg="ERROR $1"

  echo -en "HTTP/1.1 503 Service Unavailable\r\n"
  echo -en "Content-Type: text/plain\r\n"
  echo -en "Connection: close\r\n"
  echo -en "Content-Length: $((${#msg} + 2))\r\n"
  echo -en "\r\n"
  echo -en "$msg\r\n"

  sleep 0.1
  exit 1
}

success() {
  local msg="OK $1"

  echo -en "HTTP/1.1 200 OK\r\n"
  echo -en "Content-Type: text/plain\r\n"
  echo -en "Connection: close\r\n"
  echo -en "Content-Length: $((${#msg} + 2))\r\n"
  echo -en "\r\n"
  echo -en "$msg\r\n"

  sleep 0.1
  exit 0
}

check_contains() {
  [[ "$1" != *"$2"* ]] && fail "$3"
}

check_equals() {
  [[ "$1" != "$2" ]] && fail "$3"
}

check_not_equals() {
  [[ "$1" == "$2" ]] && fail "$3"
}

check_disabled() {
  [ -e "$DISABLE_FILE" ] && fail 'Node was manually disabled'
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <enable|disable>"
  exit 0
elif [[ "$1" == "disable" || "$1" == "--disable" ]]; then
  touch "$DISABLE_FILE"
elif [[ "$1" == "enable" || "$1" == "--enable" ]]; then
  rm -f "$DISABLE_FILE"
fi

check_disabled

main "$@"
