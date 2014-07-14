climate-analyser-data-server
============================

This is the OpenDAP server of the Climate Analyser project.

Installation Instructions
-------------------------

Ensure there is a **.passwd-s3fs** file in the home directory. It should
be in the format:

    bucketname:publickey:privatekey

Run **install.sh**. **install.sh** must be run under sudo as the root user.

    sudo ./install.sh
