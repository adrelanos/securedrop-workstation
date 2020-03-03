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

# Libreoffice needs to be installed here to convert to pdf to allow printing
sd-devices-install-libreoffice:
  pkg.installed:
    - name: libreoffice
    - retry:
        attempts: 3
        interval: 60
    - install_recommends: False

# Install securedrop-export package https://github.com/freedomofpress/securedrop-export
sd-devices-install-package:
  pkg.installed:
    - name: securedrop-export


sd-devices-install-securedrop-log-package:
  pkg.installed:
    - pkgs:
      - securedrop-log
    - require:
      - sls: fpf-apt-test-repo

sd-rsyslog-for-sd-devices:
  file.managed:
    - name: /etc/sd-rsyslog.conf
    - source: "salt://sd-rsyslog.conf.j2"
    - template: jinja
    - context:
        vmname: sd-devices-buster-template
