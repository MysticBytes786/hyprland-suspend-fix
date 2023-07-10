#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root. Please use sudo."
    exit 1
fi

# Create the suspend-hyprland.sh script
cat > /usr/local/bin/suspend-hyprland.sh << 'EOF'
#!/bin/bash

case "$1" in
    suspend)
        killall -STOP Hyprland
        ;;
    resume)
        killall -CONT Hyprland
        ;;
esac
EOF

# Make the script executable
chmod +x /usr/local/bin/suspend-hyprland.sh

# Create the hyprland-suspend.service systemd service file
cat > /etc/systemd/system/hyprland-suspend.service << 'EOF'
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
EOF

# Create the hyprland-resume.service systemd service file
cat > /etc/systemd/system/hyprland-resume.service << 'EOF'
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
EOF

# Reload the systemd daemon and enable the newly created services
systemctl daemon-reload
systemctl enable hyprland-suspend
systemctl enable hyprland-resume

echo "Installation complete!"