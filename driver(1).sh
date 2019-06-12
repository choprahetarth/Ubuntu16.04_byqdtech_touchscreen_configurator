#!/bin/bash
sudo apt-get --assume-yes install xserver-xorg-core
sudo apt-get --assume-yes install xserver-xorg-input-all
sudo apt-get --assume-yes install xserver-xorg-input-evdev
if [ ! -e /usr/bin/touch_ex.sh ]
then
	sudo touch /usr/bin/touch_ex.sh
	sudo chmod a+rw /usr/bin/touch_ex.sh
	echo "#!/bin/bash
	sleep 1
	sudo usb_modeswitch -v 0483 -p 5750 -d -R" >> /usr/bin/touch_ex.sh
	sudo chmod +x /usr/bin/touch_ex.sh
fi

if [ ! -e ~/.config/autostart ]
then
	mkdir ~/.config/autostart
fi

if [ ! -e ~/.config/autostart/touch_screen.desktop ]
then
	sudo touch ~/.config/autostart/touch_screen.desktop
	sudo chmod a+rw ~/.config/autostart/touch_screen.desktop
	echo "[Desktop Entry]
	Type=Application 
	Exec=/usr/bin/touch_ex.sh
	Hidden=false
	NoDisplay=false
	X-GNOME-Autostart-enabled=true
	Name=Startup Script"  >>  ~/.config/autostart/touch_screen.desktop
	sudo chmod +x ~/.config/autostart/touch_screen.desktop
fi

if [ ! -e /etc/systemd/system/touch.service ]
then
	sudo touch /etc/systemd/system/touch.service
	sleep 0.5
	sudo chmod 777 /etc/systemd/system/touch.service
	sleep 0.5
	echo "[Unit]
	Description=Touch Screen Activator
	
	[Service]
	Type=oneshot
	RemainAfterExit=no
	ExecStart=/bin/bash /usr/bin/touch_ex.sh
	
	[Install]
	WantedBy=multi-user.target" >> /etc/systemd/system/touch.service
fi

sleep 0.5
if [ ! -e /etc/udev/rules.d/80-screen.rules ]
then
	sudo touch /etc/udev/rules.d/80-screen.rules
	sleep 0.5
	sudo chmod a+rw /etc/udev/rules.d/80-screen.rules
	sleep 0.5
	echo 'ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5750", ATTRS{serial}=="497E244B3634", SYMLINK+="china_touch_screen", TAG+="systemd", ENV{SYSTEMD_WANTS}="touch.service"' >> /etc/udev/rules.d/80-screen.rules
fi

sleep 0.5
sudo systemctl restart systemd-udevd.service
sleep 0.5
sudo udevadm control --reload-rules && udevadm trigger

