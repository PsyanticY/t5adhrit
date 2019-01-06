{ region ? "us-east-1"
, vpcId ? "vpc-blabla"
, accessKeyId ? "None"
, ...
}:

{
resources.ec2SecurityGroups =
  {
   mygroup = {
        inherit region accessKeyId vpcId;
        name = "kobaySG1";
        description = "kobaySG1";
        rules = [
          { fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "11.11.11.11/32"; }
          { fromPort = 80; toPort = 80; protocol = "tcp"; sourceIp = "11.11.22.33/32"; }
        ];
      };
     mygroup2 = {
        inherit region accessKeyId vpcId;
        name = "kobaySG2";
        description = "kobaySG2";
        rules = [
          { fromPort = 22; toPort = 22; sourceIp = "11.11.11.11/32"; }
          { fromPort = 80; toPort = 80; sourceIp = "11.11.22.33/32"; }
        ];
      };
   };
}
