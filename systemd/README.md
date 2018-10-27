# Systemd

### systemd and journald how these works


#### systemd essentials

`systemd` is a suite of tools that provides a fast and flexible init model for managing linux systems.

The basic object that systemd manages and acts upon is a "unit". the most common type of unit is a service ( a unit file ending in .service)
systemd services are managed using the systemctl command.
systemctl start/stop/status/restart service_name.

By default, most systemd unit files aren't started automatically at boot. To configure this functionality, we need to "enable" to unit.
This hooks it up to a certain boot "target", causing it to be triggered when that target is started:

`systemctl enable nginx.service`
`systemctl disable nginx.service`


To show all active systemd units:
`systemctl list-units`
`systemctl list-unit-files`


__Using Targets (Runlevels)__

In systemd, "targets" are used instead of runlevels. Targets are basically synchronization points that the server can use to bring the server into a specific state.


to view the default that systemd tries to reach at boot : `systemctl get-default`


To see all of the targets available on your system, type : `systemctl list-unit-files --type=target`


To change the default target that will be used at boot: `systemctl set-default multi-user.target`


To see what units are tied to a target: `list-dependencies multi-user.target`


You can modify the system state to transition between targets with the isolate option. This will stop any units that are not tied to the specified target. Be sure that the target you are isolating does not stop any essential services: `sudo systemctl isolate multi-user.target`


For some of the major states that a system can transition to, shortcuts are available:
- To power off your server: `systemctl poweroff`
- Reboot the system: `systemctl reboot`
- Boot into rescue mode: `systemctl rescue`


#### systemd in depth

Systemd Units: Units are the objects that systemd knows how to manage. These are basically a standardized representation of system resources that can be managed by the suite of daemons and manipulated by the provided utilities.

_Types of Units_:
- `.service`: is the main one used, service unit describes how to manage a service or application on the server.
- `.target`: A target unit is used to provide synchronization points for other units when booting up or changing states.
- `.timer`: A .timer unit defines a timer that will be managed by systemd, similar to a cron job for delayed or scheduled activation.
________________________________________________________________________________

_[Unit] Section Directives_:
- `Description=`: This directive can be used to describe the name and basic functionality of the unit. It is returned by various systemd tools, so it is good to set this to something short, specific, and informative.
- `Documentation=`: This directive provides a location for a list of URIs for documentation. These can be either internally available man pages or web accessible URLs. The systemctl status command will expose this information, allowing for easy discoverability.
- `Requires=`: This directive lists any units upon which this unit essentially depends. If the current unit is activated, the units listed here must successfully activate as well, else this unit will fail. These units are started in parallel with the current unit by default.
- `Wants=`: This directive is similar to Requires=, but less strict.
- `BindsTo=`: This directive is similar to Requires=, but also causes the current unit to stop when the associated unit terminates.
- `Before=`: The units listed in this directive will not be started until the current unit is marked as started if they are activated at the same time. This does not imply a dependency relationship and must be used in conjunction with one of the above directives if this is desired.
- `After=`: The units listed in this directive will be started before starting the current unit.
- `Conflicts=`: This can be used to list units that cannot be run at the same time as the current unit. Starting a unit with this relationship will cause the other units to be stopped.
- `Condition...=`: There are a number of directives that start with Condition which allow the administrator to test certain conditions prior to starting the unit. This can be used to provide a generic unit file that will only be run when on appropriate systems. If the condition is not met, the unit is gracefully skipped.
- `Assert...=`: Similar to the directives that start with Condition, these directives check for different aspects of the running environment to decide whether the unit should activate. However, unlike the Condition directives, a negative result causes a failure with this directive.

________________________________________________________________________________

_[Install] Section Directives_: This section is optional and is used to define the behavior or a unit if it is enabled or disabled.
- `WantedBy=`: The WantedBy= directive is the most common way to specify how a unit should be enabled. This directive allows you to specify a dependency relationship in a similar way to the Wants= directive does in the [Unit] section.
- `RequiredBy=`: This directive is very similar to the WantedBy= directive, but instead specifies a required dependency that will cause the activation to fail if not met. When enabled, a unit with this directive will create a directory ending with .requires.
- `Alias=`: This directive allows the unit to be enabled under another name as well. Among other uses, this allows multiple providers of a function to be available, so that related units can look for any provider of the common aliased name.
- `Also=`: This directive allows units to be enabled or disabled as a set. Supporting units that should always be available when this unit is active can be listed here. They will be managed as a group for installation tasks.
- `DefaultInstance=`: For template units (covered later) which can produce unit instances with unpredictable names, this can be used as a fallback value for the name if an appropriate name is not provided.

________________________________________________________________________________

Unit-Specific Section Directives: Unit type-specific sections. Most unit types offer directives that only apply to their specific type.
  The device, target, snapshot, and scope unit types have no unit-specific directives, and thus have no associated sections for their type.
  The [Service] section is used to provide configuration that is only applicable for services.
    the Type= of the service need to be specified. This categorizes services by their process and daemonizing behavior. This is important because it tells systemd how to correctly manage the servie and find out its state.
    The Type= directive can be one of the following:
        simple: The main process of the service is specified in the start line. This is the default if the Type= and Busname= directives are not set, but the ExecStart= is set.
        forking: This service type is used when the service forks a child process, exiting the parent process almost immediately. This tells systemd that the process is still running even though the parent exited.
        oneshot: This type indicates that the process will be short-lived and that systemd should wait for the process to exit before continuing on with other units. This is the default Type= and ExecStart= are not set. It is used for one-off tasks.
        dbus: This indicates that unit will take a name on the D-Bus bus. When this happens, systemd will continue to process the next unit.
        notify: This indicates that the service will issue a notification when it has finished starting up. The systemd process will wait for this to happen before proceeding to other units.
        idle: This indicates that the service will not be run until all jobs are dispatched.

    Some additional directives may be needed when using certain service types. For instance:
        RemainAfterExit=: This directive is commonly used with the oneshot type. It indicates that the service should be considered active even after the process exits.
        PIDFile=: If the service type is marked as "forking", this directive is used to set the path of the file that should contain the process ID number of the main child that should be monitored.
        BusName=: This directive should be set to the D-Bus bus name that the service will attempt to acquire when using the "dbus" service type.
        NotifyAccess=: This specifies access to the socket that should be used to listen for notifications when the "notify" service type is selected This can be "none", "main", or "all. The default, "none", ignores all status messages. The "main" option will listen to messages from the main process and the "all" option will cause all members of the service's control group to be processed.

    How to manage our services. The directives to do this are:
        ExecStart=: This specifies the full path and the arguments of the command to be executed to start the process. This may only be specified once (except for "oneshot" services). If the path to the command is preceded by a dash "-" character, non-zero exit statuses will be accepted without marking the unit activation as failed.
        ExecStartPre=: This can be used to provide additional commands that should be executed before the main process is started. This can be used multiple times. Again, commands must specify a full path and they can be preceded by "-" to indicate that the failure of the command will be tolerated.
        ExecStartPost=: This has the same exact qualities as ExecStartPre= except that it specifies commands that will be run after the main process is started.
        ExecReload=: This optional directive indicates the command necessary to reload the configuration of the service if available.
        ExecStop=: This indicates the command needed to stop the service. If this is not given, the process will be killed immediately when the service is stopped.
        ExecStopPost=: This can be used to specify commands to execute following the stop command.
        RestartSec=: If automatically restarting the service is enabled, this specifies the amount of time to wait before attempting to restart the service.
        Restart=: This indicates the circumstances under which systemd will attempt to automatically restart the service. This can be set to values like "always", "on-success", "on-failure", "on-abnormal", "on-abort", or "on-watchdog". These will trigger a restart according to the way that the service was stopped.
        TimeoutSec=: This configures the amount of time that systemd will wait when starting or stopping the service before marking it as failed or forcefully killing it. You can set separate timeouts with TimeoutStartSec= and TimeoutStopSec= as well.

  The [Socket] Section: Socket units are very common in systemd configurations because many services implement socket-based activation to provide better parallelization and flexibility. Each socket unit must have a matching service unit that will be activated when the socket receives activity.
    ListenStream=: This defines an address for a stream socket which supports sequential, reliable communication. Services that use TCP should use this socket type.
    ListenDatagram=: This defines an address for a datagram socket which supports fast, unreliable communication packets. Services that use UDP should set this socket type.
    ListenSequentialPacket=: This defines an address for sequential, reliable communication with max length datagrams that preserves message boundaries. This is found most often for Unix sockets.
    ListenFIFO: Along with the other listening types, you can also specify a FIFO buffer instead of a socket.
    ...
    Accept=: This determines whether an additional instance of the service will be started for each connection. If set to false (the default), one instance will handle all connections.
    SocketUser=: With a Unix socket, specifies the owner of the socket. This will be the root user if left unset.
    SocketGroup=: With a Unix socket, specifies the group owner of the socket. This will be the root group if neither this or the above are set. If only the SocketUser= is set, systemd will try to find a matching group.
    SocketMode=: For Unix sockets or FIFO buffers, this sets the permissions on the created entity.
    Service=: If the service name does not match the .socket name, the service can be specified with this directive.

  The [Mount] Section: Mount units allow for mount point management from within systemd. Mount points are named after the directory that they control, with a translation algorithm applied.
    What=: The absolute path to the resource that needs to be mounted.
    Where=: The absolute path of the mount point where the resource should be mounted. This should be the same as the unit file name, except using conventional filesystem notation.
    Type=: The filesystem type of the mount.
    Options=: Any mount options that need to be applied. This is a comma-separated list.
    SloppyOptions=: A boolean that determines whether the mount will fail if there is an unrecognized mount option.
    DirectoryMode=: If parent directories need to be created for the mount point, this determines the permission mode of these directories.
    TimeoutSec=: Configures the amount of time the system will wait until the mount operation is marked as failed.

  The [Automount] Section: This unit allows an associated .mount unit to be automatically mounted at boot. As with the .mount unit, these units must be named after the translated mount point's path.
    Where=: The absolute path of the automount point on the filesystem. This will match the filename except that it uses conventional path notation instead of the translation.
    DirectoryMode=: If the automount point or any parent directories need to be created, this will determine the permissions settings of those path components.
  The [Swap] Section: Swap units are used to configure swap space on the system. The units must be named after the swap file or the swap device, using the same filesystem translation that was discussed above.
  Like the mount options, the swap units can be automatically created from /etc/fstab entries, or can be configured through a dedicated unit file.
    What=: The absolute path to the location of the swap space, whether this is a file or a device.
    Priority=: This takes an integer that indicates the priority of the swap being configured.
    Options=: Any options that are typically set in the /etc/fstab file can be set with this directive instead. A comma-separated list is used.
    TimeoutSec=: The amount of time that systemd waits for the swap to be activated before marking the operation as a failure.

  The [Path] Section: A path unit defines a filesystem path that systmed can monitor for changes. Another unit must exist that will be be activated when certain activity is detected at the path location. Path activity is determined thorugh inotify events.
    PathExists=: This directive is used to check whether the path in question exists. If it does, the associated unit is activated.
    PathExistsGlob=: This is the same as the above, but supports file glob expressions for determining path existence.
    PathChanged=: This watches the path location for changes. The associated unit is activated if a change is detected when the watched file is closed.
    PathModified=: This watches for changes like the above directive, but it activates on file writes as well as when the file is closed.
    DirectoryNotEmpty=: This directive allows systemd to activate the associated unit when the directory is no longer empty.
    Unit=: This specifies the unit to activate when the path conditions specified above are met. If this is omitted, systemd will look for a .service file that shares the same base unit name as this unit.
    MakeDirectory=: This determines if systemd will create the directory structure of the path in question prior to watching.
    DirectoryMode=: If the above is enabled, this will set the permission mode of any path components that must be created.

  The [Timer] Section: Timer units are used to schedule tasks to operate at a specific time or after a certain delay. This unit type replaces or supplements some of the functionality of the cron and at daemons. An associated unit must be provided which will be activated when the timer is reached.
    OnActiveSec=: This directive allows the associated unit to be activated relative to the .timer unit's activation.
    OnBootSec=: This directive is used to specify the amount of time after the system is booted when the associated unit should be activated.
    OnStartupSec=: This directive is similar to the above timer, but in relation to when the systemd process itself was started.
    OnUnitActiveSec=: This sets a timer according to when the associated unit was last activated.
    OnUnitInactiveSec=: This sets the timer in relation to when the associated unit was last marked as inactive.
    OnCalendar=: This allows you to activate the associated unit by specifying an absolute instead of relative to an event.
    AccuracySec=: This unit is used to set the level of accuracy with which the timer should be adhered to. By default, the associated unit will be activated within one minute of the timer being reached. The value of this directive will determine the upper bounds on the window in which systemd schedules the activation to occur.
    Unit=: This directive is used to specify the unit that should be activated when the timer elapses. If unset, systemd will look for a .service unit with a name that matches this unit.
    Persistent=: If this is set, systemd will trigger the associated unit when the timer becomes active if it would have been triggered during the period in which the timer was inactive.
    WakeSystem=: Setting this directive allows you to wake a system from suspend if the timer is reached when in that state.

_The [Slice] Section_: The [Slice] section of a unit file actually does not have any .slice unit specific configuration. Instead, it can contain some resource management directives that are actually available to a number of the units listed above.

________________________________________________________________________________

_Creating Instance Units from Template Unit Files_: Template unit files are, in most ways, no different than regular unit files. However, these provide flexibility in configuring units by allowing certain parts of the file to utilize dynamic information that will be available at runtime.
Template and Instance Unit Names: Template unit files can be identified because they contain an @ symbol after the base unit name and before the unit type suffix. A template unit file name may look like this: `example@.service`
When an instance is created from a template, an instance identifier is placed between the @ symbol and the period signifying the start of the unit type. For example, the above template unit file could be used to create an instance unit that looks like this: `example@instance1.service`

Template Specifiers: The power of template unit files is mainly seen through its ability to dynamically substitute appropriate information within the unit definition according to the operating environment. This is done by setting the directives in the template file as normal, but replacing certain values or parts of values with variable specifiers.
The following are some of the more common specifiers will be replaced when an instance unit is interpreted with the relevant information:
- `%n`: Anywhere where this appears in a template file, the full resulting unit name will be inserted.
- `%N`: This is the same as the above, but any escaping, such as those present in file path patterns, will be reversed.
- `%p`: This references the unit name prefix. This is the portion of the unit name that comes before the @ symbol.
- `%P`: This is the same as above, but with any escaping reversed.
- `%i`: This references the instance name, which is the identifier following the @ in the instance unit. This is one of the most commonly used specifiers because it will be guaranteed to be dynamic. The use of this identifier encourages the use of configuration significant identifiers. For example, the port that the service will be run at can be used as the instance identifier and the template can use this specifier to set up the port specification.
- `%I`: This specifier is the same as the above, but with any escaping reversed.
- `%f`: This will be replaced with the unescaped instance name or the prefix name, prepended with a /.
- `%c`: This will indicate the control group of the unit, with the standard parent hierarchy of /sys/fs/cgroup/ssytemd/ removed.
- `%u`: The name of the user configured to run the unit.
- `%U`: The same as above, but as a numeric UID instead of name.
- `%H`: The host name of the system that is running the unit.
- `%%`: This is used to insert a literal percentage sign.

#### Journad

_Viewing Basic Log Information_: A systemd component called journald collects and manages journal entries from all parts of the system. This is basically log information from applications and the kernel.
- `journalctl`
- `journalctl -b`: only from the current boot
- `journalctl -k`:only kernel messages
- `journalctl -u nginx.service`: To see all of the journal entries for the unit in question
- `systemctl cat nginx.service`: To see the full contents of a unit file
- `systemctl list-dependencies nginx.service`: To see the dependency tree of a unit (which units systemd will attempt to activate when starting the unit)
- `systemctl list-dependencies --all nginx.service`: recursive dependencies
- `systemctl show nginx.service`: the low-level details of the unit's settings on the system

Systemd-journald can be configured to grow its files up to a percentage of the size of the volume it’s hosted in.
The daemon would then automatically delete old journal entries to keep the size below that threshold.

Journald.conf:
- `SystemKeepFree`: This is one of the several parameters that control how large the journal can grow up to. This parameter applies if systemd is saving journals under the /var/log/journal directory. It specifies how much disk space the systemd-journald daemon will leave for other applications in the file system where the journal is hosted. The default is 15%.
- `SystemMaxuse`: This parameter controls the maximum disk space the journal can consume when it’s persistent. This defaults to 10% of the disk space.
- `SystemMaxFileSize`: This specifies the maximum size of a journal file for persistent storage. This defaults to one-eighth of the size of the SystemMaxUse parameter.
- `MaxRetentionSec`: The maximum time to store entries in the journal. Journal files containing records which are older than this period will be deleted automatically.
- `MaxLevelStore`:	This parameter can take any of the following values: ... All messages equal or below the level specified will be stored on disk. The default value is “debug” which means all log messages from “emerg” to “debug”.
- `SystemMaxFiles` and `RuntimeMaxFiles`: control how many individual journal files to keep at most. Note that only archived files are deleted to reduce the number of files until this limit is reached; active files will stay around. This means that, in effect, there might still be more journal files around in total than this limit after a vacuuming operation is complete. This setting defaults to 100.
- `MaxRetentionSec`: The maximum time to store journal entries. This controls whether journal files containing entries older then the specified time span are deleted. Normally, time-based deletion of old journal files should not be required as size-based deletion with options such as SystemMaxUse= should be sufficient to ensure that journal files do not grow without bounds. However, to enforce data retention policies, it might make sense to change this value from the default of 0 (which turns off this feature). This setting also takes time values which may be suffixed with the units "year", "month", "week", "day", "h" or " m" to override the default time unit of seconds.

Check journald disk usage: `journalctl --disk-usage`

So we basically have the following limits on journald log size:
limit by size
limit by number of files
limit by date

default size limit: 4GB.
default file number limit: 100 files max.

#### Resources:

[Systemd essential](https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal)

To get more in depth look for these in the above web site bottom page:
* [How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
* [How To Use Journalctl to View and Manipulate Systemd Logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)
* [Understanding Systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
