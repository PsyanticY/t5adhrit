Q: How am I supposed to copy files to /var/lib from the $out directory in the postinstall phase?

A: During a build nothing can end up outside of the nix store

A: if you use nixos, then you have activationScript which does this kind of tasks, it can go in systemd preStart hooks too
