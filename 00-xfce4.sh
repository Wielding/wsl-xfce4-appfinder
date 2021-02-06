# start the dbus-daemon and xfsettingsd if they exits to
# allow for XFCE4 themes to work as well as other global appication
# settings
#
# place this file in /etc/profile.d

set - e

# Save stdout and stderr
exec 6>&1
exec 5>&2

# Redirect stdout and stderr to a file
exec > ./.00-xfce4.log
exec 2>&1


if [ -n "${WSL_INTEROP}" ]; then
        export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
    else
        export DISPLAY=localhost:0.0
fi

export NO_AT_BRIDGE=1

#if dbus-daemon is installed then load it
if (command -v dbus-daemon >/dev/null 2>&1); then
        if  [ -z $(pidof dbus-launch) ]; then
                eval "$(timeout 2s dbus-launch --auto-syntax &)"
        fi
fi

if [ -z $(pidof xfsettingsd) ]; then
        cd ~
        xfsettingsd --sm-client-disable &
fi

# Restore stdout and stderr
exec 1>&6 6>&-
exec 2>&5 5>&-
