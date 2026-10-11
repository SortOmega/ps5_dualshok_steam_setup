# Steam Input - PS5 controller compability on Linux

A simple guide on how to set your PS5 controller to be compatible with Steam Input on Linux.

If your controllers work everywhere (Your system and Steam Big Picture) but not on games, then you just need to do the following steps:
#### 1) Check whether your distro already has the udev rules (run into your terminal):

```bash
ls /usr/lib/udev/rules.d/*steam* 
```
The above will list the udev file's location if it exists. It might show any of the following files `60-steam-input.rules` or `70-steam-input.rules`

#### 2) Update or create the udev files
```bash
sudo nano /usr/lib/udev/rules.d/60-steam-input.rules
```
```bash 
sudo nano /usr/lib/udev/rules.d/70-steam-input.rules
```
Then paste the udev rules at the end of the file:
```
# PS5 DualSense over USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

# PS5 DualSense over Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

# DualSense Edge USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"

# DualSense Edge Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
```
Save and close the file after pasting.

#### 2) Reload Steam and udev rules
First close Steam completely, then run the following commands:
```
sudo udevadm control --reload-rules
```
```
sudo udevadm trigger
```
After that, reconnect your controller, and finally launch Steam and start playing  (optionally disable and enable Steam Input again before starting to play, just in case).
