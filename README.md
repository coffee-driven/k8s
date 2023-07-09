# k8s

K8S on KVM/QEMU

Tested on Debian 11
WIP

### Pre configuration

##### Install libvirt

##### Due to bug in Terrafrom qemu security driver must be configured to none

1. Add/Uncomment `security_driver = "none"` directive in `/etc/libvirt/qemu.conf`
2. restart Libvirt daemon `systemctl restart libvirtd`

##### Enable console 

- `systemctl enable serial-getty@ttyS0.service`
- `systemctl start serial-getty@ttyS0.service`

**!**
Inventory plugin for libvirt cannot be configured for specific network only. It returns all VMs launched by user!
