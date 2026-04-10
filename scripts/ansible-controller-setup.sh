#!/bin/bash

hostnamectl set-hostname titan.saber.net

dnf install --assumeyes ansible-core
dnf install --assumeyes ansible

