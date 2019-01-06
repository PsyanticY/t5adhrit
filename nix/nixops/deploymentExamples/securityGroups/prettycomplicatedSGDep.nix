# when attached, destroying the security group fails,
# when adding a rule we need to add --check


{ vpcId ? "vpc-xxxxxx"
, accessKeyId ? "dovah"
, region ? "us-east-1"
, description? "know true pain"
, akinRules ? false
, toPort ? null
, fromPort ? null
, rulesFile ? ./rules.nix
, ...
}:
{

network.description = description;

resources.ec2SecurityGroups = with (import ../generic.nix { akinRules = akinRules; toPort = toPort; fromPort = fromPort; region = region; accessKeyId = accessKeyId;});
    let
      rules = import rulesFile;
    in
      {
         group1 = createSecurityGroups "sg1" "desc1" vpcId rules.set1;
         group2 = createSecurityGroups "sg1" "desc2" vpcId rules.set2;
      };
}

#rules.nix
{
set1 = [
  { fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "11.11.11.11/32"; }
  { fromPort = 80; toPort = 80; protocol = "tcp"; sourceIp = "11.11.22.33/32"; }
];
set2 = [
  { fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "11.11.11.11/32"; }
  { fromPort = 80; toPort = 80; protocol = "tcp"; sourceIp = "11.11.22.33/32"; }
];
}


# generic.nix
{ accessKeyId ? "dovah"
, region ? "us-east-1"
, fromPort ? null
, toPort ? null
, akinRules ? false
, ...
}:
let
  mapping = ip:
    {
      fromPort = fromPort; toPort = toPort; sourceIp = "${ip}";
    };
in
  {
    createSecurityGroups = name: description: vpc: rules:
      {
        inherit accessKeyId region;
        vpcId = vpc;
        description = description;
        name = name;
        rules = if akinRules then (map mapping rules) else rules;
      };
  }
