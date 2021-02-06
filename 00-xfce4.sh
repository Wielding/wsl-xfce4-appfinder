# Start the dbus-daemon and xfsettingsd if they exits to
# allow for XFCE4 themes to work as well as other global appication
# settings
#
# place this file in /etc/profile.d.

if [ -n "${WSL_INTEROP}" ]; then
    export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
    
else
    export DISPLAY=localhost:0.0
fi

export NO_AT_BRIDGE=1

#if dbus-daemon is installed then load it
if (command -v dbus-daemon >/dev/null 2>&1); then   
    if [ -z $(pidof dbus-launch) ]; then
        eval "$(timeout 2s dbus-launch --auto-syntax)"
    fi
fi

if [ -z $(pidof xfsettingsd) ]; then
    cd ~
    xfsettingsd --sm-client-disable
fi
