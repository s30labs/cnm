#!/bin/bash

ansible-playbook -c local -i /cfg/ansible.hosts  fix-cert.yml
