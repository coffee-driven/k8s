Configure sysctl parameters.

Example inventory data:

```
sysctl_conf:
  - name: net.core.somaxconn
    value: '8192'
    state: present
  
  - name: net.core.rmem_default
    value: '65536'
    state: present
  
  - name: net.core.rmem_max
    value: '8388608'
    state: present
```
