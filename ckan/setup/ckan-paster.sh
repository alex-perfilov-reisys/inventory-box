#!/bin/bash

cd ~
. pyenv/bin/activate
cd pyenv/src/ckan

paster --plugin=ckan db init

paster --plugin=ckan user add admin password=admin email=admin@domain.local --config=development.ini
paster --plugin=ckan sysadmin add admin --config=development.ini