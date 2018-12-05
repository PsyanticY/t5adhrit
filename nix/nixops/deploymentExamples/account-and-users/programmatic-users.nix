# we collect here all info specific to an account.
{

  "dovah-kin".uid = 5555;
  "dovah-kin".group = "hellonix";
  "dovah-kin".localKeyDir = "dovah-kin";
  "dovah-kin".remoteSecretDir = "/home/dovah-kin/.secrets";
  "dovah-kin".ec2Key = "blablablalblalabla blallablablablalbablablabla <accessKeyId-name>";
  "dovah-kin".sshPrivKey = (builtins.readFile ./ssh-id_rsa);
  "dovah-kin".sshPubKey = (builtins.readFile ./ssh-id_rsa.pub);
  "dovah-kin".sshConfig = (builtins.readFile ./ssh-config);

  # localKeyDir: dir found in /run/keys-${localKeyDir}
  # remoteSecretDir: where secret is to be copied

  # same for each user you gonna add.
  # ...
  # ...
}
