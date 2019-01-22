# Disk formatting and encryption

### Encrypting filesystem:

* Create a file system (ext4 in this case):
`mkfs.ext4 /dev/sdf`
* Encrypted the newly formatted disk:
`cryptsetup -y luksFormat /dev/sdf`: Enter the encryption password in this step
* Open/Unlock the encrypted device and give it a name (`data`):
`cryptsetup luksOpen /dev/sdf data`
* Format the encrypted device:
`mkfs.ext4 /dev/mapper/data`
* Finally mounted Volume:
`mount /dev/mapper/data /data`

 __Whenever w need to close the encrypted device we can use:__
`cryptsetup luksClose /dev/mapper/data`

__Whenever we need to resize the encrypted volume__

```bash
cryptsetup resize /dev/mapper/data
xfs_growfs /disk/mounted/path
```

### Other usefull stuff:
To check if our system support encryption to disks:
`grep -i config_dm_crypt /boot/config-$(uname -r)`.

To make sure we have the cryptsetup utility:

```
$ lsmod | grep dm_crypt
$ modprobe dm_crypt
$ lsmod | grep dm_crypt
```
To install it, Run: `yum/apt-get install cryptsetup`

* check filesystem type: `lsblk -f`
* fix xfs filesystem (make sure it is not mounted) : `xfs_repair /dev/xvdg`

### Mount NFS filesystem:

```shell
yum install nfs-utils nfs-utils-lib
mount nfsserverIPAdress:/home/ /home/nfs_home
```

### Resizing disk with parted

[Expanding a Linux Partition](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/expand-linux-partition.html)

[Extending a Linux File System after Resizing the Volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html)

First make sure parted is installed

_This is to make sure the root volume is MBR (msdos) and not GPT_

```
parted /dev/xvda print
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 17.2GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  8590MB  8589MB  primary  ext4         boot```
```

```
parted /dev/xvda
GNU Parted 2.1
Using /dev/xvda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) unit s
(parted) print
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 33554432s
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start  End        Size       Type     File system  Flags
 1      2048s  16777215s  16775168s  primary  ext4         boot

(parted) rm 1
(parted) mkpart primary 2048s 100%
(parted) print
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 33554432s
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start  End        Size       Type     File system  Flags
 1      2048s  33554431s  33552384s  primary  ext4

(parted) set 1 boot on
(parted) print
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 33554432s
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start  End        Size       Type     File system  Flags
 1      2048s  33554431s  33552384s  primary  ext4         boot

(parted) quit
Information: You may need to update /etc/fstab.
```
```
e2fsck -f /dev/xvda1
e2fsck 1.41.12 (17-May-2010)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/xvda1: 18680/524288 files (0.2% non-contiguous), 258010/2096896 blocks
```

_now we extend the volume_

```
resize2fs /dev/xvda1
resize2fs 1.41.12 (17-May-2010)
Resizing the filesystem on /dev/xvda1 to 4194048 (4k) blocks.
The filesystem on /dev/xvda1 is now 4194048 blocks long.
```
