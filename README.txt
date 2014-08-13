GETTING STARTED
===============

Option 1: install project on a virutal machine (recommended method)
------------------------------------------

 1) Install VirtualBox & Vagrant on your developement environnement.

 2) Download the base box:

    vagrant box add eyp https://username:password@path/to/vagrant/debian.box

 3) Start and provision the VM: vagrant up

 4) It is up and running at http://localhost:8080 and you can login
    into the VM: vagrant ssh - admin login and password is "vagrant".

Option 2: install EYP on your machine
-------------------------------------

You need to have a working LAMP stack with proper configuration.

 1) svn co https://path/to/svn/EYP/trunk or git pull

 2) Run libstall.sh to download all librairies (composer)

 3) Run phing (build script)

Now it is installed on www/ folder. You will have to configure your
Apache Virtual Host to use that folder.
