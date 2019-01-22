{ deploymentName ? "deployment"
, title ? "deployment Timeboard"
, description ? "deployment timeboard to visualize different mertics"
, ...
}:

let
  apiKey = builtins.readFile ./datadog-api.key;
  appKey = builtins.readFile ./datadog-app.key;

  # This can be further improved or maybe passed as args.
  deviceNames = ["xvdf" "xvda"];
  DiskStorageMetrics = ["system.disk.free" "system.disk.used"];
  diskStoragePercentage = ["system.disk.in_use" "system.disk.total"];
  DiskIOMetrics = ["system.io.r_s" "system.io.w_s"];
  systemMetrics = ["system.cpu.iowait" "system.cpu.idle" "system.swap.used" "system.swap.free" "system.mem.free" "system.mem.used"]; # CPU RAM and SWAP
  totalMemoryUsage = ["system.mem.total" "system.swap.total"];
  listOfPossibleDevices = [ "xvdf" "xvdg" "xvdh" "xvdi" "xvdj" "xvdk" "xvdl" "xvdm" "xvdn" "xvdo" "xvdp" "xvdq"];
  
  # this assumes that any disk other than the root one is encrypted.
  diskMetricQuery = {device, metric}:
    {
      # this is kinda of crappy but yeah 
      q= if builtins.any (ac: device == ac) (listOfPossibleDevices)
        then "avg:${metric}{$Deployment,device:/dev/mapper/${device}} by {host}"
        else "avg:${metric}{$Deployment,device:/dev/disk/by-label/nixos} by {host}";
      aggregator="avg";
      type="line";
    };
  diskUsage = {devices, metric}:
    {
      title = "${metric}";#for ${map (x: (x + " ")) device}"; FIXME
      definition = builtins.toJSON {
        requests = map (device: (diskMetricQuery { inherit metric device; }) ) devices;
        viz= "timeseries";
      };
    };

  diskIOMetrics = {device, metric}:
    {
      q= "avg:${metric}{$Deployment,device:${device}} by {host}";
      aggregator="avg";
      type="line";
    };
  diskIOUsage = {devices, metric}:
    {
      title = "${metric}";#for ${map (x: (x + " ")) device}"; FIXME
      definition = builtins.toJSON {
        requests = map (device: (diskIOMetrics { inherit metric device; }) ) devices;
        viz= "timeseries";
      };
    };

  diskStorage = {device, metric}:
    {
      title = "${metric} for the ${device} device";#for ${map (x: (x + " ")) device}"; FIXME
      definition = builtins.toJSON {
        requests = [{
          q = if builtins.any (ac: device == ac) (listOfPossibleDevices)
            then "top(max:${metric}{$Deployment,device:/dev/mapper/${device}} by {host}, 10, 'max', 'desc')"
            else "top(max:${metric}{$Deployment,device:/dev/disk/by-label/nixos} by {host}, 10, 'max', 'desc')";
        }];
        viz= "toplist";
      };
    };
    systemHardwareUsage = {metric}:
      {
        title = "${metric}";
        definition = builtins.toJSON {
          requests = [{
            aggregator="avg";
            type="line";
            q = "avg:${metric}{$Deployment} by {host}";
          }];
          viz= "timeseries";
        };
      };
      memroyTotalUsage = {metric}:
        {
          title = "${metric}";
          definition = builtins.toJSON {
            requests = [{
              q = "top(max:${metric}{$Deployment} by {host}, 10, 'max', 'desc')";
            }];
            viz= "toplist";
          };
        };

in
{
  resources.datadogTimeboards.deployment-timeboard =
    { config, lib, ...}:
    {
      inherit title description appKey apiKey;
      readOnly = true;
      templateVariables = [
        {
          name = "Deployment";
          prefix = "deployment";
          default = deployment;
        }
      ];
       graphs = (lib.flatten ( map (metric: (diskUsage {devices=deviceNames; inherit metric;})) (DiskStorageMetrics)))
         ++ (lib.flatten ( map (metric: (diskIOUsage {devices=deviceNames; inherit metric;})) (DiskIOMetrics)))
         ++ (lib.flatten (map (metric: (map (device: (diskStorage {inherit metric device;})) (deviceNames)))(diskStoragePercentage)))
         ++ (lib.flatten (map (metric: ( systemHardwareUsage {inherit metric;})) systemMetrics ))
         ++ (lib.flatten (map (metric: (memroyTotalUsage {inherit metric;})) totalMemoryUsage ));
    };
}
