{ enableEscalation ? false
, alertedUsers ? [] # peoples that will receive the alerts
, escalateToUsers ? [] # when enableEscalation is set, people to escalate to.
, datadogProcesses ? [] # list of processes that datadog will be monitoring (sshd or zabbix_agentd for example :p)
, ...
}:
with import <nixpkgs/lib>;
{


  defaults =

    {config, pkgs, lib, ...}:
    {
      # this Should be updated for datadog agent v6 on 18.09.
      services.dd-agent.processConfig = lib.mkOverride 10 ( if datadogProcesses!=[] then ''
        init_config:
        instances:
        ${concatMapStrings (x: "  - name: "+x +"\n"+ "    search_string: ['" + x +"']\n") datadogProcesses}
      '' else "");
    };
  resources.datadogMonitors =

    let
      apiKey = builtins.readFile ./datadog-api.key;
      appKey = builtins.readFile ./datadog-app.key;

      systemServices = service:
        { config, lib, resources, ...}:

        let
          deployment = "${toLower config.deployment.name}";
        in

        {
          inherit apiKey appKey;
          name = "[${deployment}]: ${service} on {{host.name}} not working";
          type = "service check";
          query = ''
            "process.up".over("deployment:${deployment}","process:${service}").last(2).count_by_status()
          '';
          message = ''
            The systemd unit ${service} failed or not running please run `systemctl status` UNIT_NAME for more information.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 3;
            new_host_delay = 300;
            # test this for when a service is oneshot
            notify_no_data = true;
            thresholds.critical = 1;
            } // (
                escalation "${service} has been in a failed state/not running for over an hour"
              )
          );
        };

      escalation = msg:(if enableEscalation then
        {
          escalation_message = ''
            ${msg}
            ${if escalateToUsers!=[] then concatMapStrings (x: " @"+x) escalateToUsers else ""}
          '';
          renotify_interval = 60;
        }
        else {});
    in

    {
      no-data-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] {{host.name}} no data is being collected";
          type = "service check";
          query = ''"datadog.agent.up".over("deployment:${toLower config.deployment.name}").by("host").last(1).count_by_status()'';
          message = ''
            No data is being collected from {{host.name}}, this generally indicates that the host is no longer reachable,
            please investigate
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            notify_no_data = true;
            thresholds.critical = 1;
            } // (
              escalation "No data has been collected from {{host.name}} for over an hour"
              )
          );
        };

      memory-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] Usable memory in {{host.name}} is under 3Gb";
          type = "metric alert";
          query = "avg(last_10m):avg:system.mem.usable{deployment:${toLower config.deployment.name}} by {host} < 3221225472";
          message = ''
            The usable memory in {{host.name}} is very low, this can impact the system performance.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 3221225472;
            } // (
                escalation "The usable memory is above the critical threshold for over an hour"
              )
          );
        };

      cpu-idle-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] Idle CPU percentage in {{host.name}} is under 10% for the last 10 min";
          type = "metric alert";
          query = "avg(last_10m):avg:system.cpu.idle{deployment:${toLower config.deployment.name}} by {host} < 10";
          message = ''
            The Idle CPU in {{host.name}} is very low, this can impact the system performance.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 10;
            } // (
                escalation "The Idle CPU is below the critical threshold for over an hour"
              )
          );
        };

      inode-free-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] Free Inode in {{host.name}} are under 1000";
          type = "metric alert";
          query = "avg(last_10m):avg:system.fs.inodes.free{deployment:${toLower config.deployment.name}} by {host} < 1000";
          message = ''
            Free Inode in {{host.name}} is very low, this can impact the system performance.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 1000;
            } // (
                escalation "Free Inode is below the critical threshold for over an hour"
              )
          );
        };

      swap-memory-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] SWAP memory in {{host.name}} is under 1 GB";
          type = "metric alert";
          query = "avg(last_10m):avg:system.swap.free{deployment:${toLower config.deployment.name}} by {host} < 1070000000";
          message = ''
            SWAP in {{host.name}} is very low, this can impact the system performance.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 1070000000;
            } // (
                escalation "SWAP memory is below the critical threshold for over an hour"
              )
          );
        };

      system-uptime-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] {{host.name}} recently rebooted";
          type = "metric alert";
          query = "max(last_5m):avg:system.uptime{deployment:${toLower config.deployment.name}} by {host} < 1800";
          message = ''
            {{host.name}} recently rebooted, please investigte.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 1800;
            thresholds.critical = 1800;
            }
          );
        };

      cpu-iowait-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] CPU IO wait in {{host.name}} is above 90%";
          type = "metric alert";
          query = "avg(last_10m):avg:system.cpu.iowait{deployment:${toLower config.deployment.name}} by {host} > 90";
          message = ''
            CPU IO wait in {{host.name}} is very high, this can impact the system performance.
            ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 90;
            } // (
                escalation "CPU IO wait is above the critical threshold for over an hour"
              )
          );
        };

      disk-usage-monitor =
        { config, ...}:
        {
          inherit apiKey appKey;
          name = "[${config.deployment.name}] disk space on {{host.name}}:{{device.name}} is under 10%";
          type = "metric alert";
          query = "max(last_15m):"+
          "( 100 * max:system.disk.free{deployment:${toLower config.deployment.name},!device:devtmpfs,!device:tmpfs} by {device,host} ) /"+
          " max:system.disk.total{deployment:${toLower config.deployment.name},!device:devtmpfs,!device:tmpfs} by {device,host} <= 10";
          message = ''
          Available disk space on {{host.name}}, {{device.name}} is under 10%. Please run `df -h` for more informations.
          ${concatMapStrings (x: " @"+x) alertedUsers}
          '';
          monitorOptions = builtins.toJSON ({
            no_data_timeframe = 30;
            new_host_delay = 300;
            thresholds.critical = 10;
            } // (
              escalation "Low available disk space on {{host.name}}/{{device.name}} for over an hour"
              )
          );
        };
    } // (
      builtins.listToAttrs (map (s: nameValuePair "${s}-monitor" (systemServices s) ) datadogProcesses)
    );
}


/* sshd-monitor =
{ config, ...}:
{
    inherit apiKey appKey;
    name = "[${config.deployment.name}] sshd service on {{host.name}} is not working";
    type = "service check";
    query = ''"process.up".over("deployment:nixos-hardened-image","process:sshd").last(2).count_by_status()'';
    message = ''
    The sshd service on {{host.name}} is not working.
    ${concatMapStrings (x: " @"+x) alertedUsers}
    '';
    monitorOptions = builtins.toJSON ({
    no_data_timeframe = 3;
    new_host_delay = 300;
    thresholds.critical = 2;
    notify_no_data = true;
    } // (
        escalation "SSHD is not working on {{host.name}} for more than an hour"
        )
    );
}; */