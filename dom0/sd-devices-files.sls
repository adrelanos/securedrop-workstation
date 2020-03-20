# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# sd-devices-files
# ========
#
# Moves files into place on sd-devices
#
##
include:
  - fpf-apt-test-repo
  - sd-logging-setup

# Libreoffice needs to be installed here to convert to pdf to allow printing
sd-devices-install-libreoffice:
  pkg.installed:
    - name: libreoffice
    - retry:
        attempts: 3
        interval: 60
    - install_recommends: False

# Install securedrop-export package https://github.com/freedomofpress/securedrop-export
# Temporary: Install local svs-disp package
sd-devices-install-package:
  file.managed:
    - name: /opt/securedrop-export.deb
    - source: salt://sd/sd-workstation/securedrop-export_0.2.2+buster_all.deb
    - mode: 644
  cmd.run:
    - name: apt install -y /opt/securedrop-export.deb
