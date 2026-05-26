# Device Inventory

Inventory captured from the ChromeOS host over SSH.

## Identity

```text
ChromeOS device code: boxy-rev3
ChromeOS board: dedede-signed-mp-v58keys
Hardware ID: BOXY-GLMX C3W-C2D-B3B-A6C-A9E
Firmware ID: Google_Boxy.13606.594.0
Read-only firmware ID: Google_Boxy.13606.594.0
Active firmware slot: A
Active firmware type: developer
```

## ChromeOS Release

```text
CHROMEOS_RELEASE_DESCRIPTION=16640.40.0 (Official Build) stable-channel dedede
CHROMEOS_RELEASE_VERSION=16640.40.0
CHROMEOS_RELEASE_CHROME_MILESTONE=148
CHROMEOS_RELEASE_TRACK=stable-channel
CHROMEOS_RELEASE_BUILD_TYPE=Official Build
CHROMEOS_RELEASE_BOARD=dedede-signed-mp-v58keys
GOOGLE_RELEASE=16640.40.0
```

Kernel:

```text
Linux localhost 6.1.161-17590-gf0e6dabf73de #1 SMP PREEMPT_DYNAMIC Mon, 11 May 2026 22:37:28 -0700 x86_64 Intel(R) Celeron(R) N4500 @ 1.10GHz GenuineIntel GNU/Linux
```

## Developer Mode

```text
devsw_boot = 1
devsw_cur = 1
mainfw_type = developer
recoverysw_boot = 0
recoverysw_ec_boot = 0
```

## CPU and Memory

```text
CPU: Intel(R) Celeron(R) N4500 @ 1.10GHz
Cores: 2
Architecture: x86_64
Virtualization: Intel VMX present
Memory: 7.6 GiB
Swap: 15 GiB zram
```

## PCI Devices

Important PCI devices:

```text
Intel JasperLake UHD Graphics
Intel Jasper Lake USB 3.1 xHCI Host Controller
Intel Wi-Fi 6 AX201 160MHz
Intel Jasper Lake eMMC Controller
Intel Jasper Lake HD Audio
Realtek RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller
```

## USB Devices

Observed USB devices:

```text
Linux Foundation 3.0 root hub
Intel AX201 Bluetooth
Areson Technology Corp / Elecom MR-K013 Multicard Reader
Linux Foundation 2.0 root hub
```

## Storage

Main disk:

```text
mmcblk1 28.9G eMMC
```

Important filesystems:

```text
/dev/root                3.4G  2.9G  444M  87% /
/dev/mmcblk1p1            20G   13G  6.6G  66% /mnt/stateful_partition
/dev/mapper/encstateful  5.8G  1.1G  4.7G  19% /mnt/stateful_partition/encrypted
```

Notes:

- ChromeOS root filesystem is read-only.
- `/mnt/stateful_partition` is the writable persistent partition.
- `/usr/local` is backed by the stateful partition and can hold local tools.
- User home areas are mounted with `noexec`; scripts there may not run directly.

## Network

Observed interfaces:

```text
lo      127.0.0.1/8
wlan0   192.168.1.45/24
vmtap6  100.115.92.25/30
eth0    DOWN
```

Crostini routing:

```text
100.115.92.24/30 dev vmtap6 src 100.115.92.25
100.115.92.192/28 via 100.115.92.26 dev vmtap6
```

## Crostini

Observed running VM/container stack:

```text
crosvm running
VM: termina
container: penguin
container IPv4: 100.115.92.26
container OS: Debian GNU/Linux 13 (trixie)
```

The ChromeOS host uses `vsh` to enter the container.

