#!/bin/bash
PROJECTADDRESS=/home/ferdosian/yaml-script/project/pwa-3rdparty/.gitlab-ci.yml
sudo sed -i 's|$PREG/docker-base-images/kuberunner:v1|$PREG/docker-base-images/kuberunner:v2|g' $PROJECTADDRESS
