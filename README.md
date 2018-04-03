# Rackspace Private Cloud Deployment Tool

rpc-deploy is used for deploying bare metal in customer environments.  This repo will
take a deployment.yml that contains information about the environment, set up a DHCP server,
TFTP, and HTTP services and then generate the relevent configurations to boot the systems,
update them and configure them to the appropriate specifications.

This tool leverages the iPXE project which enables support for things like IPv6, UEFI, and more
secure boot options.

This uses the old style method of looking for MAC addresses on the disk to guide and provision
the servers in an environment.  This tool is fed a YAML which contains all of the information
about an enviornment and will generate all of the installation PXE files, generate the preseeds,
and handle the boot process of the servers in the environment based on the information fed in
via the YAML inventory.

*This is a work in progress.  More notes about the idea of this project can be seen
[here](https://etherpad.rax.io/p/rpc-deploy-v1).*

## Deployment Configuration

Copy the example config and create the deployment.yaml:

    cp configs/deployment.yaml.example configs/deployment.yaml

Edit the file, set up all of the global configurations, and then create an entry under systems
for each server.

## Set up the Deployment server

Running build.sh without any options will install any required packages, generate iPXE disks,
setup DHCP and setup the filesystem layout.  By default, preflight and provisioning configurations
are not generated.  

    ./build.sh

If you'd like all servers in the environment to be set up, you'll need to generate configurations
that will be picked up when the servers boot.  There are several states available that the server can run in:

|State|Purpose|Data Destructive|
|-----|-------|-----------|
|preflight|Loads Utility image, applies Firmware/RAID/OBM updates for detected hardware|yes|
|provision|Installs the OS to the hardware|yes|
|firmware|Updates all firmware and then boots back into OS|no|

If these files are present under the MAC Address configuration directory, it will roll through each state
and upon completion remove that state from the server.

For a new environment being provisioned, you'll want to specify these options:

    PREFLIGHT=true PROVISION_ENVIRONMENT=true ./build.sh

This will generate the PXE directory structure that will be looked up when the servers boot.  The servers
look for a configuration directory that matches the MAC address of the host network NIC.  It then attempts
to load the various states and execute the appropriate script if it's available.  If all scripts have been run,
then the server will attempt to localboot.  

Preflight will direct the server to update firmware, configure Out of Band Management, and configure RAID.
Provision will boot the server into the OS and configure it based on the generated preseed/kickstart.

### Environment Variables for build.sh

|Variable|Default|Description|
|--------|-------|-----------|
|PREFLIGHT|false|Generates preflight configuration files|
|PROVISION_ENVIRONMENT|false|Generates OS install files|
|UPDATE_FIRMWARE|false|Generates configs to update firmware|

## rpc-deploy iPXE Bootloader [![Build Status](https://travis-ci.org/rcbops/rpc-deploy.svg?branch=master)](https://travis-ci.org/rcbops/rpc-deploy)

![rpc-deploy-bootloader](images/rpc-deploy-bootloader.jpeg)

The bootloader is an iPXE generated boot disk that contains operator options for setting up the inital
deployment server of a Rackspace Private Cloud as well as other items used for bring the servers up to
the desired production specifications.  It includes options for setting up an initial deployment server
automatically if a deployment.yml is specified, setting up Out of Band Management on the server and
upating the firmware.  

This tool is useful in fresh deployments to get the initial server off the ground
in the datacenter so that the remaining operations can be handled remotely.  The latest releases of the
bootloader are generated on every commit to the rpc-deploy repo and are generated via Travis CI
[here](https://github.com/rcbops/rpc-deploy/releases/latest).

The deployment repo is a location that contains the deployment.yml which describes the environment. It
is used for the generation of the PXE configs to automate installation of the environment.

## Utility image

The [Utility image](https://github.com/rcbops/rpc-deploy-utility-image) is a CentOS LiveOS image that is
loaded onto the servers.  Based on the options passed to the kernel command line, it will look at that
and run the appropriate Ansible [playbooks](https://github.com/rcbops/rpc-deploy-utility).  CentOS is
used as most hardware providers build their utilities for RedHat operating systems so CentOS is typically
the best OS to run the various tools from Dell/HP/etc.  

### Deployment Filesystem layout and System Booting

##### TFTP Server

Located in /var/lib/tftpboot contains iPXE boot files.  HTTP is preferred once initial iPXE kernel has been loaded from TFTP.

##### HTTP Server

Located in /var/www/pxe, URLs started with http://deploy_server_ip/:

|File URL|Purpose|
|--------|-------|
|/boot.ipxe|Boot script file for iPXE that checks for actions|
|/ipxe.*|iPXE bootloader files|
|/images/utility|Contains local copy of Utility Image files|
|/pxe/00-00-00-00-00-00/| MAC Address configuration directory|
|/pxe/00-00-00-00-00-00/{provision,preflight,firmware}| Used for determining action to run on boot|
|/pxe/00-00-00-00-00-00/configs/interfaces.sh| Generates the interfaces file|
|/pxe/00-00-00-00-00-00/configs/preseed | Generated preseed configuration file|
|/pxe/00-00-00-00-00-00/configs/settings.{ipxe,yml} | Contains variables that can be loaded in Ansible or iPXE|

##### System Booting

Once iPXE gets on the network, it attempts to load boot.ipxe.  It looks up the Mac Address URL from the HTTP Server and checks and sees if the various action files are present.  If they are, it will run the action within that file.  Upon completion of that action, that file is deleted so that the action is not ran again on the next boot.  It will then attempt to load the next action until no more are present for the MAC directory.  At that point it will localboot, or boot the OS.

##### UEFI Boot Mode

Add notes for UEFI here... (WIP)

In UEFI mode, Ubuntu will add a EFI bootloader files to the EFI partition.  The installer adds the ubuntu boot as the first option on HP servers which overrides networking boot loading.  In order to rekick, the ubuntu bootloader needs to be removed using the efibootmgr.  To delete the ubuntu bootloader you can run efibootmgr to get the ID of the ubuntu bootloader and then delete it using:

    efibootmgr -b 00018 -B

By removing the bootloader, this will allow the server to network boot again in the case a rekick is needed.  If the OS is not functioning, then the boot order could be changed via the OBM to network boot on the next boot to do a reinstall.  The order could be changed post install but there are complications exiting out of iPXE at this time in EFI mode and getting it to actually load.  (at least on HPs)  That remains to be worked through.

##### Legacy Boot Mode

Add notes for Legacy here...
