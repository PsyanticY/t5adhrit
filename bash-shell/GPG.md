# GPG Stuff

Get my gpg key:

                  gpg --armor --export dovah.kin@pain.com

Decrypt:

                  gpg --output aws-creds.txt --decrypt credentials.csv.gpg

Encrypt:

                  gpg --encrypt --armor --recipient alice@example.com --recipient bob@example.com doc.txt

List gpg keys :

                  gpg --list-keys

Import a key:

                  gpg --import name
