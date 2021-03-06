#!/usr/bin/env python3
"""
Admin wrapper script for applying salt states for staging and prod scenarios. The rpm
packages only puts the files in place `/srv/salt` but does not apply the state, nor
does it handle the config.
"""
import sys
import argparse
import subprocess
import os

SCRIPTS_PATH = "/usr/share/securedrop-workstation-dom0-config/"
SALT_PATH = "/srv/salt/sd/"

sys.path.insert(1, os.path.join(SCRIPTS_PATH, "scripts/"))
from validate_config import SDWConfigValidator, ValidationError  # noqa: E402


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--apply",
        default=False,
        required=False,
        action="store_true",
        help="Apply workstation configuration with Salt",
    )
    parser.add_argument(
        "--validate",
        default=False,
        required=False,
        action="store_true",
        help="Validate the configuration",
    )
    parser.add_argument(
        "--uninstall",
        default=False,
        required=False,
        action="store_true",
        help="Completely Uninstalls the SecureDrop Workstation",
    )
    args = parser.parse_args()

    return args


def copy_config():
    """
    Copies config.json and sd-journalist.sec to /srv/salt/sd
    """
    try:
        subprocess.check_call(
            ["sudo", "cp", os.path.join(SCRIPTS_PATH, "config.json"), SALT_PATH]
        )
        subprocess.check_call(
            ["sudo", "cp", os.path.join(SCRIPTS_PATH, "sd-journalist.sec"), SALT_PATH]
        )
    except subprocess.CalledProcessError:
        raise SDAdminException("Error copying configuration")


def provision_all():
    """
    Runs provision-all to apply the salt state.highstate on dom0 and all VMs
    """
    try:
        subprocess.check_call([os.path.join(SCRIPTS_PATH, "scripts/provision-all")])
    except subprocess.CalledProcessError:
        raise SDAdminException("Error during provision-all")


def validate_config(path):
    """
    Calls the validate_config script to validate the config present in the staging/prod directory
    """
    try:
        validator = SDWConfigValidator(path)  # noqa: F841
    except ValidationError:
        raise SDAdminException("Error while validating configuration")


def perform_uninstall():

    try:
        subprocess.check_call(
            ["sudo", "qubesctl", "state.sls", "sd-clean-default-dispvm"]
        )
        print("Destroying all VMs")
        subprocess.check_call(
            [os.path.join(SCRIPTS_PATH, "scripts/destroy-vm"), "--all"]
        )
        subprocess.check_call(
            [
                "sudo", "qubesctl", "--skip-dom0", "--targets",
                "whonix-gw-15", "state.sls", "sd-clean-whonix"
            ]
        )
        print("Reverting dom0 configuration")
        subprocess.check_call(
            ["sudo", "qubesctl", "state.sls", "sd-clean-all"]
        )
        subprocess.check_call(
            [os.path.join(SCRIPTS_PATH, "scripts/clean-salt")]
        )
        print("Uninstalling Template")
        subprocess.check_call(
            ["sudo", "dnf", "-y", "-q", "remove", "qubes-template-securedrop-workstation-buster"]
        )
        print("Uninstalling dom0 config package")
        subprocess.check_call(
            ["sudo", "dnf", "-y", "-q", "remove", "securedrop-workstation-dom0-config"]
        )
    except subprocess.CalledProcessError:
        raise SDAdminException("Error during uninstall")

    print(
        "Instance secrets (Journalist Interface token and Submission private key) are still"
        "present on disk. You can delete them in /usr/share/securedrop-workstation-dom0-config"
    )


def main():
    args = parse_args()
    if args.validate:
        print("Validating...")
        validate_config(SCRIPTS_PATH)
    elif args.apply:
        print("Applying configuration...")
        validate_config(SCRIPTS_PATH)
        copy_config()
        provision_all()
    elif args.uninstall:
        print(
            "Uninstalling SecureDrop workstation will uninstall all packages and destroy all VMs"
        )
        response = input("Are you sure you would want to uninstall (y/N)? ")
        if response.lower() != 'y':
            print("Exiting.")
            sys.exit(0)
        else:
            perform_uninstall()
    else:
        sys.exit(0)


class SDAdminException(Exception):
    pass


if __name__ == "__main__":
    main()
