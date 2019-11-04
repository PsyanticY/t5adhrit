# Shell/Bash tips and tricks:

### Shell shortcuts:

- `ctrl a` : beginning of line.
- `ctrl e` : end.
- `ctrl k` : delete the front of cursor.
- `ctrl l` : clear the ascreen and leave the current line only.
- `ctrl u` : reverse ctrl k.
- `ctrl w` : clear the last word.
- `ctrl t` : switch spot .
- `ctrl h` : delete one lettre.
- `ctrl d` : delete one letter front .


### Search:

- `which`: look for the path of a command
- `whereis`: look for the pathc and man of a command
- `locate`: look for a file based on word
- `find`:
   * `find . -name 'cron*'`
   * `find . -type f -name 'cron*'` only file names
   * `find . -type d -name 'cron*'` only directory names
   * `find /home -perm 777` list all file with permission 777
   * `find /home -perm 777 -exec chmod 555 {} \;`
   * `find / -mtime +1` find all the files that have been modified in the last day
   * `find / -a +1` accessed files
   * `find / -group groupname`
   * `find . -size 512c`
   * `find / -size 1M`
   * `find . -name 'file*' -exec rm {} \;`


### Text and file manipulation

`cat file* | wc -l`  the number pf lines in all our files.

- `grep text file1`.
- `grep -c ^text file1`: match all the lines that begin with hello for -c count.
- `egrep -i 'hello.*world' fole1`: -i for ignore case.
- `egrep -i 'hello|word' file1`: find patterns that contain either hello or world.
- `egrep -v 'hello|world' file1`: -v for do not contain.
- `fgrep = grep -F`: fgrep interpet literally (speed is a concern and we dont use regular expressions).
- `grep "psyyyy" -irl`: check for psyyy in local directory

wild cards:
* `*`    : whatever caractere
* `?`    : one caractere
* `[rR]` : the first field of the file name will contains either r or R
* `[e]`  : files that eend with e
* `[0-5]`: range

- `cut -f1 -d: passwd`.
- `cut -f7 -d: passwd`.
- `cut -d = -f 4`: cut a string into peices based on a delimiter and extract the 4 field .

- `sed 's/pattern/replacement/' file1`.
- `sed 's/pattern/replacement/w promotion.txt' file1`: Write the changes to the new file promotion.
- `sed '0,/pattern/s/replacement/promotion' file`.

- `test -f file1 && echo "true"`: Echo true if the file exist.
- `test -f file1 && echo "true"`: Test if it is writable.

__WIP__: sed / awk   check em

__Loop through and read tow lines at a timefrom a file__

```bash

while read -r ONE; do
    read -r TWO
    echo "ONE: $ONE TWO: $TWO"
done < testfile.txt
```

### Linux filesystem tree:

- `mnt`: is  mount place for devices and drives in general.
- `bin/sbin`: binary system program.
- `proc`: kernel and where the information are stored.
- `var`: where web sites are located.
- `boot`: files for booting.
- `etc`: most programs hold their config files.
- `opt`: install optional additional programs.
- `root`: home folder for root.
- `usr`: (unix system resource).
- `srv`: service data located.
- `sys`: data exported from the kernel about subsystems.


### User information:

- Users information file : `/etc/passwd` : The format is a s follow : `username:password:UID:GID:comments:home_dir:shell`. If the password field have x then the password is stored in the shadow file.
- Password are stored in `/etc/shadow` which is only readable by the super user.
- `/etc/skel` typically contains shell configuration files.
- `/etc/group` contains the group we create.

- `identification`: a user say that he is a given user (their can be a false claim) (username).
- `authentication`: in this step the user prove what he claim he is  (password, ...).
- `authorization`: see if the user in allowed to do some given thing   (access control list).
- `authntication`: factors: something u know something u have something u are.

- `getent passwd`: check all the account on a machine.
- `getent networks`: check all the networks .
- `getent services`: check all the services .
- `gpasswd`: name of the group : set a password for the group.


### Others:

`2>` : standad error.

`. something/test.sh` = `source something/test.sh`.

`chage -l `: list password changes history

`useradd -D`: show the default user conf.

### Log rotation

https://www.networkworld.com/article/3218728/linux/how-log-rotation-works-with-logrotate.html

### CSRF

http://opensourceforu.com/2010/11/securing-apache-part-3-xsrf-csrf/

### Multipathd

https://www.thegeekdiary.com/beginners-guide-to-device-mapper-dm-multipathing/

### ssl

- Testing SSL: `openssl s_client -connect www.feistyduck.com:443`

- Checking certificate : `openssl x509 -in cert-name.crt -text -noout`

- Checking certificate (just the date): `openssl x509 -in cert-name.crt -text -noout`

### Getting users from

- `cut -d: -f1 /etc/passwd` or  `awk -F: '{ print $1}' /etc/passwd`

### Warmup

- ```nohup seq 0 $(($(cat /sys/block/xvdf/size) / (1 << 10))) | xargs -n1 -P `nproc` -I {} sudo dd if=/dev/xvdf of=/dev/null skip={}k count=1 bs=512 > warm.txt 2>&1 & ```