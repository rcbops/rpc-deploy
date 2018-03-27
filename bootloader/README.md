# rpc-deploy bootloader

This directory contains the scripts to generate an iPXE bootloader
used for initial setup of the deployment system when getting
starting out with a fresh environment.

Given the location of your deployment.yml, it will setup your deployment
server, give you the option to setup remote access to the deployment
server, and other initial tools to make the deployment of your RPC
environment easier.

To create a USB key to start the deployment see the instructions below on where to download the latest bootloader release and how to create a key.

# Releases

For the latest bootloader release you can download them [here](https://github.com/rcbops/rpc-deploy/releases/latest).

|Type|Bootloader|Description|
|----|----------|-----------|
|USB|rpc-deploy-bootloader.usb|Used for making an rpc-deploy bootloader|

# Creating the USB Key

** Note: Creating a USB Key will remove any data on the device, make sure you've backed up everything on the key. **

## Creating USB Key on Linux

Insert a USB key in your compute and find the device name. Then use following command:

    cat rpc-deploy-bootloader.usb > /dev/sdX

or

    dd if=rpc-deploy-bootloader.usb of=/dev/sdX

where sdX is your usb drive.

The USB key should be ready to eject once finished.

### Creating USB Key on MacOS

__Run:__

    diskutil list

to get the current list of devices

___Insert the flash media.___

__Run:__

    diskutil list

again and determine the device node assigned to your flash media (e.g. /dev/disk2).

__Run:__

    diskutil unmountDisk /dev/diskN

(replace N with the disk number from the last command; in the previous example, N would be 2).

__Execute:__

    sudo dd if=rpc-deploy-bootloader.usb of=/dev/rdiskN bs=1m

* Using /dev/rdisk instead of /dev/disk may be faster
* If you see the error dd: Invalid number '1m', you are using GNU dd. Use the same command but replace bs=1m with bs=1M
* If you see the error dd: /dev/diskN: Resource busy, make sure the disk is not in use. Start the 'Disk Utility.app' and unmount (don't eject) the drive

__Run:__

    diskutil eject /dev/diskN

and remove your flash media when the command completes.

### Creating USB Key on Windows

Check out [Rufus](https://rufus.akeo.ie/) to install the ISO file to a USB key.

### Booting

Once you've created your key, reboot and set your BIOS to load the USB key first if it's not set for that already. You should see iPXE load up either load up rpc-deploy automatically or prompt you to set your networking information up.
