#!/usr/bin/env bash

#######################################################################################################################
# This script was written to make Rasperry Pi Kiosk setup easy for everyone and will perform the following actions:   #
#   1. Capture the desired URL/URI for your Pi Kiosk Mode Display                                                     #
#   2. Install Unclutter, update system package info, as well as Raspian OS to latest version                         #
#   3. Install the latest version of Chromium                                                                         #
#   4. Create your autostart file with Kiosk mode configured to URL/URI provided in #1                                #
# Given the nature of this script, it must be executed with elevated privileges, i.e. with `sudo`.                    #
#                                                                                                                     #
# Remember, with great power comes great responsibility.                                                              #
#                                                                                                                     #
# Do not be in the habit of executing scripts from the internet with root-level access to your machine. Only trust    #
# well-known publishers, and even then, read the script first to be safe.                                             #
#######################################################################################################################

set -e

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

captureKioskUri () {
    user "What is the URL you wish to boot Raspberry Pi to?"
    read KIOSK_URI
    info "URL captured as: $KIOSK_URI"
}

raspiConfig () {
    sudo bash -c "cat <<EOF > /etc/xdg/lxsession/LXDE-pi/autostart
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash

@xset s off
@xset -dpms
@xset s 0 0
@xset s noblank
@xset s noexpose
@xset dpms 0 0 0
@chromium-browser --noerrdialog --disable-infobars --autoplay-policy=no-user-gesture-required --check-for-update-interval=1 --simulate-critical-update --kiosk $KIOSK_URI
EOF
"
if [ $? -eq 0 ]; then
   success "configured autostart with provided url: $KIOSK_URI"
else
   fail "there was a problem configuring your autostart file. please try again."
fi
}

install () {
    sudo apt install unclutter -y > /dev/null 2>&1 && success 'unclutter installed'

    sudo apt-get update > /dev/null 2>&1 && success 'system package info updated'

    sudo apt-get dist-upgrade -y > /dev/null 2>&1 && success 'raspian OS updated to latest version'

    sudo apt-get install -y rpi-chromium-mods > /dev/null 2>&1 && success 'chromium installed'
}

rebootNow () {
    success 'system fully configured'
    while true; do
    read -p "Would you like to reboot now? y/n (Press enter after selection) " yn
    case $yn in
        [Yy]* ) sudo reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please select yes or no.";;
    esac
    done
}

captureKioskUri
install
raspiConfig
rebootNow