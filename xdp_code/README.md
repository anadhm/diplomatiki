The XDP filter is located @ filters/xdp_prog_kern.c
Dependencies:
* llvm, libelf-dev, libpcap-dev, gcc-multilib, build-essential
* linux-headers-$(uname -r)

Serialized form of morton filter is in filters/output.txt

* cd filters && make 

How to load the filter:

* sudo ./xdp_loader -d [device_name] --auto-mode --progsec xdp_morton_filter

How to unload the filter:
* sudo ./xdp_loader -d [device_name] --auto-mode -U && sudo rm /sys/fs/bpf/[device_name]/morton_filter
  * loader creates new directory for the bpf map, doesn't delete it on unload so it should be done manually