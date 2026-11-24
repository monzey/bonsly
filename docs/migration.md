# Initial host migration

This procedure is retained for installations that have not migrated to host-specific outputs.
Its presence does not mean migration is still pending on either machine. Check the actual
machine and active configuration before choosing an output.

First migration: use `home-manager switch --flake ./home-manager#monzey@<host>` to install the new
update script. On the home PC, whose old hostname may still be `muk`, first use `sudo nixos-rebuild
switch --flake ./nixos#gardevoir` to apply the correct hardware and rename it. Never select `muk`
there based on the old hostname.
