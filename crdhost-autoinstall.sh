#!/bin/bash -x
#
# Startup script to install Chrome remote desktop and a desktop environment.
#
# See environmental variables at then end of the script for configuration
#

function install_desktop_env {
  PACKAGES="desktop-base xscreensaver dbus-x11"

  if [[ "$INSTALL_XFCE" != "yes" && "$INSTALL_CINNAMON" != "yes" ]] ; then
    # neither XFCE nor cinnamon specified; install both
    INSTALL_XFCE=yes
    INSTALL_CINNAMON=yes
  fi

  if [[ "$INSTALL_XFCE" = "yes" ]] ; then
    PACKAGES="$PACKAGES xfce4"
    echo "exec xfce4-session" > /etc/chrome-remote-desktop-session
    [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
      PACKAGES="$PACKAGES task-xfce-desktop"
  fi

  if [[ "$INSTALL_CINNAMON" = "yes" ]] ; then
    PACKAGES="$PACKAGES cinnamon-core"
    echo "exec cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session
    [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
      PACKAGES="$PACKAGES task-cinnamon-desktop"
  fi

  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes $PACKAGES $EXTRA_PACKAGES

  systemctl disable lightdm.service
}

function download_and_install { # args URL FILENAME
  if [[ -e "$2" ]] ; then
     echo "cannot download $1 to $2 - file exists"
     return 1;
  fi
  curl -L -o "$2" "$1" && \
    apt-get install --assume-yes --fix-broken "$2" && \
    rm "$2"
}

function is_installed {  # args PACKAGE_NAME
  dpkg-query --list "$1" | grep -q "^ii" 2>/dev/null
  return $?
}

# Configure the following environmental variables as required:
INSTALL_XFCE=yes
INSTALL_CINNAMON=no
INSTALL_CHROME=yes
INSTALL_FULL_DESKTOP=yes

# Any additional packages that should be installed on startup can be added here
EXTRA_PACKAGES="less bzip2 zip unzip tasksel wget"

apt-get update

if ! is_installed chrome-remote-desktop; then
    if [[ ! -e /etc/apt/sources.list.d/chrome-remote-desktop.list ]]; then
        echo "deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main" \
            | tee -a /etc/apt/sources.list.d/chrome-remote-desktop.list
    fi
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
    apt-get update
    DEBIAN_FRONTEND=noninteractive \
        apt-get install --assume-yes chrome-remote-desktop
fi

install_desktop_env

[[ "$INSTALL_CHROME" = "yes" ]] && ! is_installed google-chrome-stable && \
  download_and_install \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    /tmp/google-chrome-stable_current_amd64.deb

echo "Chrome remote desktop installation completed"
