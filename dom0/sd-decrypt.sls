# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# sd-decrypt
# ========
#
# Configures the 'sd-decrypt' template VMs
# This should be a disposable VM, but due to a Qubes bug we're using a
# non-disposable VM for the time being.
##

sd-decrypt:
  qvm.vm:
    - name: sd-decrypt
    - present:
      - template: fedora-28
      - label: green
    - prefs:
      - netvm: ""

# tell qubes this VM can be used as a disp VM template
qvm-prefs sd-decrypt template_for_dispvms True:
  cmd.run

# tag this vm, since we need to set policies using it as a source
# (eg, "dispvms created from this VM can use the Gpg facility provided
# by sd-gpg"), but the "$dispvm:sd-decrypt" syntax can only be used as an
# RPC policy *target*, not source. Tagged VMs can be used as a source.
# This feels like a Qubes bug.
qvm-tags sd-decrypt add sd-decrypt-vm:
  cmd.run

# Allow dispvms based on this vm to use sd-gpg
sd-decrypt-dom0-qubes.qubesGpg:
  file.prepend:
    - name: /etc/qubes-rpc/policy/qubes.Gpg
    - text: "$tag:sd-decrypt-vm sd-gpg allow\n"

# Allow sd-decrypt to open files in sd-svs
sd-decrypt-dom0-qubes.OpenInVM:
  file.prepend:
    - name: /etc/qubes-rpc/policy/qubes.OpenInVM
    - text: "sd-decrypt sd-svs allow\n"
