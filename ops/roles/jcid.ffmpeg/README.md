# !!! Notch8 moded this repo to compile nasm, since centos 7 and redhat enterprise doesn't come with a new enough version (>= 2.13)

# Ansible role for FFmpeg

A role to compile FFmpeg and it's major dependencies from sources and install it all.

Based on:

1. [Official FFmpeg compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)

2. [Ansible role FFmpeg for Ubuntu / Debian](https://galaxy.ansible.com/list#/roles/1696)

Requirements
------------

none

Installation
------------

This role requires at least Ansible `v1.4.0`. To install it, run:

    ansible-galaxy install jcid.FFmpeg-for-CentOS
