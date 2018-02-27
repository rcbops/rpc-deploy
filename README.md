# Rackspace Private Cloud Deployment Tool

** EXPERIMENTAL, this is a Work in Progress **

Need to generate docs but the basic idea is that this will take a node in an environment
and set up DHCP, TFTP, and HTTP on it for the purposes of provisioning servers in an
environment.

This leverages the iPXE project which enables support for things like IPv6, UEFI, and more
secure boot options.

This uses the old style method of looking for MAC addresses on the disk to guide and provision
the servers in an environment.  This tool is fed a YAML which contains all of the information
about an enviornment and will generate all of the installation PXE files, generate the preseeds,
and handle the boot process of the servers in the environment based on the information fed in
via the YAML inventory.

*This is a work in progress.  More notes about the idea of this project can be seen
[here](https://etherpad.rax.io/p/rpc-deploy-v1).*

The current goal is to just guide a server to boot and provision with the basic network.
(network config generation is currently out of scope as this is handled post today and 
needs to cover many types of environments).  This will be expanded out to managing firmware,
and lifecycle of the hardware, and may eventually integrate this into an inventory
management system.

