#! /bin/bash

run_checks () {
  if ! ping -c1 -q google.com > /dev/null ; then
    echo "No internet connection."
    exit 1
  elif ! id | grep -q root ; then
    echo "Not root! (try sudo $0)"
    exit 1
  fi
}

update_upgrade () {
  run_checks
  printf "\nCHECKING FOR SOFTWARE UPDATES ...\n\n"
  apt update && apt upgrade
}

update_dist_upgrade () {
  run_checks
  printf "\nCHECKING FOR KERNEL UPDATES ...\n\n"
  apt update && apt dist-upgrade
}

update_autoremove () {
  run_checks
  printf "\nCHECKING FOR REMOVABLE SOFTWARE ...\n\n"
  apt update && apt autoremove
}

if [ -z "$1" ] ; then
  update_upgrade
else
  for input_options ; do
    case "$input_options" in
      -u|--update) update_upgrade ;;
      -k|--kernel) update_dist_upgrade ;;
      -r|--autoremove) update_autoremove ;;
    esac
  done
fi

