# ssh Stuff

- To Remove passphrase from the private ssh key: 
                
                ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
                or jus use 
                ssh-keygen
                and let the terminal ask for the rest

- My `.ssh/config` file:

                User nagato.pain
                Host *
                ForwardAgent yes

