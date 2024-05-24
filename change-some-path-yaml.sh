#!/bin/bash
PROJECTADDRESS=/home/ferdosian/yaml-script/project/ap-wallet-neobank-management/ci/k8s/ap-wallet-neobank-management-ingress.yaml
sudo yq e -i '.apiVersion = "networking.k8s.io/v1"' $PROJECTADDRESS
#=======================================================================================
#get all port
#=======================================================================================
# Extract all service ports from the YAML file
service_ports=$(yq e '.spec.rules[].http.paths[].backend.servicePort' $PROJECTADDRESS)

# Convert the extracted ports to a list
IFS=$'\n' read -rd '' -a port_list <<<"$service_ports"

# Print the list
printf '%s\n' "${port_list[@]}"
#=======================================================================================
yq eval 'del(.spec.rules[].http.paths[].backend.serviceName, .spec.rules[].http.paths[].backend.servicePort)' $PROJECTADDRESS > temp-file-some.yaml
sudo cp temp-file-some.yaml  $PROJECTADDRESS
sudo cp temp-file-some.yaml  $PROJECTADDRESS
sudo sed -i 's/{}//' $PROJECTADDRESS 
sudo yq e '.spec.rules[].http.paths[].backend = {"service": {"name": "$CI_PROJECT_NAME", "port": {"number": "flag" }}}' $PROJECTADDRESS > temp-file-some.yaml
sudo cp temp-file-some.yaml $PROJECTADDRESS
COUNT_OF_NUMBER=$(grep -oE 'number: flag' "$PROJECTADDRESS" | wc -l)
for ((i=0; i<$COUNT_OF_NUMBER; i++));do
PORT_NUMBER=${port_list[$i]}
sudo sed -i '0,/flag/{s/flag/'$PORT_NUMBER'/}' $PROJECTADDRESS
done
cat $PROJECTADDRESS 





