# k8s

Tested on Debian 11

### Pre configuration

Due to bug in Terrafrom qemu security driver must be configured to none 

1. Add/Uncomment `security_driver = "none"` directive in `/etc/libvirt/qemu.conf`
2. restart Libvirt daemon `systemctl restart libvirtd`
