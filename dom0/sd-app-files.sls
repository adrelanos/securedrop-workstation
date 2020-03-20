# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# sd-app-files
# ========
#
# Moves files into place on sd-app-template
#
##
include:
  - fpf-apt-test-repo
  - sd-logging-setup

# FPF repo is setup in "securedrop-workstation" template
# TEMPORARY: use local client package
install-securedrop-client-package:
  file.managed:
    - name: /opt/securedrop-client.deb
    - source: salt://sd/sd-workstation/securedrop-client_0.1.3+buster_all.deb
    - mode: 644
  cmd.run:
    - name: apt install -y /opt/securedrop-client.deb
