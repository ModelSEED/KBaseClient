KBaseClient

A client installation to utilize KBase servers

INSTALLATION

To install this application, run the following commands:

1.) Install perlbrew (perlbrew… is awesome!)
curl -kL http://install.perlbrew.pl | bash
source ~/perl5/perlbrew/etc/bashrc

2.) Install and switch to perl-5.16.0 (nohup the first step… it can take an hour)
perlbrew install perl-5.16.0
perlbrew switch perl-5.16.0

3.) Install carton in your perl brew installation
perl -MCPAN -e shell
<say "yes" to all prompts>
install Carton
<say "yes" to all prompts>
exit

4.) Checkout the Kbase client package
git clone git://github.com/ModelSEED/KBaseClient.git

5.) Install KBase client dependencies
cd KBaseClient
carton install

6.) Source the environment (and if you don't add the perlbrew source to your bash profile, add it to the beginning of the user-env.sh script in KBaseClient)
source KBaseClient/user-env.sh

7.) Try running the login command:
kbws-login kbasetest -p "@Suite525"

MAINTENANCE

This app contains scripts and libs extracted from other KBase modules: workspace_service, auth, and KBaseFBAModeling. These must be periodically updated to maintain this module. To do this, ensure that the dependent modules are checked out in the same directory as KBaseClient, and then run the following commands:

1.) Clear out existing binary files
make clean

2.) Gather scripts and libs from other modules
make gather

3.) Regenerate the binary files
make all

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

LICENSE AND COPYRIGHT

Copyright (C) 2012 Christopher Henry

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.