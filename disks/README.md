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

### Other usefull stuff:

To make sure we have the cryptsetup utility:

```
$ lsmod | grep dm_crypt
$ modprobe dm_crypt
$ lsmod | grep dm_crypt
```
To install it, Run: `yum/apt-get install cryptsetup`

[WIP]

### parted

[WIP]
