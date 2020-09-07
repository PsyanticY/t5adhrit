# ssh Stuff

- To Remove passphrase from the private ssh key: 
                
                ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
                or jus use 
                ssh-keygen
                and let the terminal ask for the rest

- My `.ssh/config` file:

                User psyanticy
                Host *
                ForwardAgent yes
                StrictHostKeyChecking no
                CanonicalizeHostname yes
                CanonicalDomains dovah.kin

- Generate an ssh key:

                ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
