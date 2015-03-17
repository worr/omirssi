# Dependencies #

Obviously, omirssi requires irssi and perl. However, it also requires the perl module WWW::Omegle which you probably don't have, and which is probably not present in your OS's package manager. Install it using CPAN below.

```
# perl -MCPAN -e shell
cpan[1]> install WWW::Omegle
```

# Script Installation #

After downloading the tar archive provided, extract it in your home directory. It will pop the omirssi.pl script right in your ~/.irssi/scripts directory. If you want to install it system wide, move it to /usr/share/irssi/scripts or where ever your OS puts your system irssi scripts.