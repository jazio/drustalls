
Drupal Bash Scripts

### Install a Drupal [7 or 8] instance
===============================
####Make your script your own:
```
$ chown {username} drustall.sh
```
####Run script -- you will be asked which version of Drupal to install: 7 or 8
```
$ ./drustall.sh
```

### ./newhost.sh Install a new Apache host
Contains scripts to create a virtual host for your site.
```
$ sudo ./newhost.sh
```

Known bugs
When installation folder exits but database was deleted script is interupted.