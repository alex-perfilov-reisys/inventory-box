#!/bin/bash

cd ~
virtualenv pyenv
. pyenv/bin/activate
pip install --ignore-installed -e git+https://github.com/GSA/ckan.git@inventory#egg=ckan
pip install --ignore-installed -r pyenv/src/ckan/requirements.txt

deactivate
. pyenv/bin/activate

cd pyenv/src/ckan
paster make-config ckan development.ini
deactivate