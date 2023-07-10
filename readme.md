# This solution aims to resolve the issue where Hyprland crashes when waking up on systems with an NVIDIA GPU

### the problem

Hyprland is attempting to communicate with the NVIDIA driver after it has already entered suspend mode, so it cannot respond. Linux tries to freeze the task but fails because Hyprland is waiting for a response from the driver and cannot be frozen.

### the solution

The solution is to manually suspend Hyprland using the STOP signal before the NVIDIA driver goes into suspend mode. Then use the CONT signal upon resuming.

## Solution Overview

The solution involves the following steps:

1. Create a script `suspend-hyprland.sh` to suspend and resume Hyprland.

2. Create systemd services `hyprland-suspend.service` and `hyprland-resume.service` to manage the suspension and resumption of Hyprland.

3. Reload the systemd daemon and enable the newly created services.
---

#### Step 1: Create the script

Create a script `suspend-hyprland.sh`:

```
#!/bin/bash

case "$1" in
    suspend)
        killall -STOP Hyprland
        ;;
    resume)
        killall -CONT Hyprland
        ;;
esac

```
#### Step 2: Create the systemd services

Create a systemd service `hyprland-suspend.service`:

```

[Unit]
Description=Suspend hyprland
Before=systemd-suspend.service
Before=systemd-hibernate.service
Before=nvidia-suspend.service
Before=nvidia-hibernate.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/suspend-hyprland.sh suspend

[Install]
WantedBy=systemd-suspend.service
WantedBy=systemd-hibernate.service

```

Create a systemd service `hyprland-resume.service`:

```
[Unit]
Description=Resume hyprland
After=systemd-suspend.service
After=systemd-hibernate.service
After=nvidia-resume.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/suspend-hyprland.sh resume

[Install]
WantedBy=systemd-suspend.service
WantedBy=systemd-hibernate.service

```

#### Step 3: Reload the systemd daemon and enable the newly created services

`sudo systemctl daemon-reload`

`sudo systemctl enable hyprland-suspend.service`

`sudo systemctl enable hyprland-resume.service`


