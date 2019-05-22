# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# sd-svs-disp
# ========
#
# Configures the 'sd-svs-disp' template VM, which will be used as the
# base dispvm for the SVS vm (will be used to open all submissions
# after processing).
# This VM has no network configured.
##

include:
  - sd-workstation-template

sd-svs-disp-template:
  qvm.vm:
    - name: sd-svs-disp-template
    - clone:
      - source: securedrop-workstation
      - label: green
    - require:
      - sls: sd-workstation-template

sd-svs-disp:
  qvm.vm:
    - name: sd-svs-disp
    - present:
      - template: sd-svs-disp-template
      - label: green
    - prefs:
      - netvm: ""
      - template_for_dispvms: True
    - tags:
      - add:
        - sd-workstation
        - sd-svs-disp-vm
    - require:
      - qvm: sd-svs-disp-template
