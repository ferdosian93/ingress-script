#!/bin/bash

GROUP_ID="15"
GITLAB_TOKEN="glpat--U3Q_wss3a_gNui4e4yj"
GITLAB_HOST="https://gitlab.tasn.ir"
CURRENT_DIRECTORY=$(pwd)
INGRESS_NAME="*-ingress.yaml"
INGRESS_FILES_ARRAY=()

# GitLab API endpoint to list group projects
API_ENDPOINT="https://gitlab.tasn.ir/api/v4/groups/$GROUP_ID"
# Array to store metadata
all_metadata=()

# Loop to fetch metadata for all pages
page=1
while true; do
    response=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "${API_ENDPOINT}/projects?page=${page}&per_page=100")
    echo "111111111111111111111111"

    #Check if response is empty or an empty array
    if [ -z "$response" ] || [ "$response" == "[]" ]; then
        break
    fi
    echo "222222222222222222222222"
    all_metadata+=("$response")
    ((page++))
done
    echo "333333333333333333333333"
# Check if metadata was fetched successfully
if [ ${#all_metadata[@]} -gt 0 ]; then
    # Extract metadata from JSON responses
    repo_names=($(echo "${all_metadata[@]}" | jq -r '.[].name'))
    echo $repo_names
    
    # Print group metadata
    for ((i=0; i<${#repo_names[@]}; i++)); do
     if [ -d "${repo_names[$i]}" ]; then
        echo "=====================${repo_names[$i]} already exist======================="
     else
   	    git clone --branch master https://m.ferdosian:Aa123456@gitlab.tasn.ir/ap/pwa/frontend/${repo_names[$i]}.git 
        echo "############### cloned ${repo_names[$i]} ##################"
     fi
    done
fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++checking repos for finding ci directory++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
     
     for ((j=0; j<${#repo_names[@]}; j++)); do
        echo "================================${repo_names[$j]}===================================="
            cd "${repo_names[$j]}"
            sudo git branch change-ingress-version
        if [ -d "ci" ]; then
            echo  "++++++++++++++++ "${repo_names[$j]}" project has ci directory+++++++++++++++"
            cd ci/k8s
                for FILE in *-ingress*; do
                    # Check if the file exists and is a regular file
                    if [ -f "$FILE" ]; then
                      # Add filename to the array
                        INGRESS_COUNT_ARRAY+=("$FILE")
                        echo $FILE
                        API_VERSION=$(yq e '.apiVersion' $FILE)
                        BACKEND_PARAMETER_COUNT=$(yq eval-all '.[]' "$FILE" | grep -c '\- backend')
                        echo "count of backend is "$BACKEND_PARAMETER_COUNT
                            if [ $API_VERSION != "networking.k8s.io/v1" ] && [ $BACKEND_PARAMETER_COUNT > 1 ];then
                                sudo git branch "change-ingress-version"
                                sudo git checkout change-ingress-version
                                touch temp-file.yaml
                                sudo yq e -i '.apiVersion = "networking.k8s.io/v1"' $FILE
                                # Extract all service ports from the YAML file
                                SERVICE_PORTS=$(yq e '.spec.rules[].http.paths[].backend.servicePort' $FILE)
                                IFS=$'\n' read -rd '' -a port_list <<<"$SERVICE_PORTS"
                                printf '%s\n' "${port_list[@]}"
                                yq eval 'del(.spec.rules[].http.paths[].backend.serviceName, .spec.rules[].http.paths[].backend.servicePort)' $FILE > temp-file.yaml
                                #sudo yq e 'del(.spec.rules[0].http.paths[0].backend.serviceName, .spec.rules[0].http.paths[0].backend.servicePort | select(. == null))' $FILE > temp-file.yaml
                                sudo cp temp-file.yaml  $FILE
                                sudo sed -i 's/{}//' $FILE
                                sudo yq e '.spec.rules[].http.paths[].backend = {"service": {"name": "$CI_PROJECT_NAME", "port": {"number": "flag" }}}' $FILE > temp-file.yaml
                                sudo cp temp-file.yaml $FILE
                                echo $FILE
                                COUNT_OF_NUMBER=$(grep -oE 'number: flag' "$FILE" | wc -l)
                                     for ((k=0; k<$COUNT_OF_NUMBER; k++));do
                                        echo $k
                                        PORT_NUMBER=${port_list[$k]}
                                        sudo sed -i '0,/flag/{s/flag/'$PORT_NUMBER'/}' $FILE
                                     done
                                cat $FILE
                                sudo rm -f temp-file.yaml
                                sudo rm -f 1
                                cd ../../
                                sed -i 's/image: \$PREG\/docker-base-images\/kuberunner:v1/image: \$PREG\/docker-base-images\/kuberunner:v2/g' .gitlab-ci.yml
                                #sudo git add .
                                #sudo git commit -am "change ingress version and gitlab-ci kubrunner"
                                #sudo git push -f origin change-ingress-version
                                #sudo git push -o merge_request.create
                            
                            elif [ $API_VERSION != "networking.k8s.io/v1" ] && [ $BACKEND_PARAMETER_COUNT==1 ];then
                                sudo git branch "change-ingress-version"
                                sudo git checkout change-ingress-version
                                touch temp-file.yaml
                                echo "versionesh ghadimiye vaaaaaaaaaaaaaay bayad change she??????????"
                                sudo yq e -i '.apiVersion = "networking.k8s.io/v1"' $FILE
                                PORTNUMBER=$(sudo yq e '.spec.rules[0].http.paths[0].backend.servicePort' $FILE)
                                echo "$PORTNUMBER"
                                sudo yq e 'del(.spec.rules[0].http.paths[0].backend.serviceName, .spec.rules[0].http.paths[0].backend.servicePort | select(. == null))' $FILE > temp-file.yaml
                                sudo cp temp-file.yaml  $FILE
                                sudo yq e '.spec.rules[0].http.paths[0].backend = {"service": {"name": "$CI_PROJECT_NAME", "port": {"number": '$PORTNUMBER'}}}' $FILE > temp-file.yaml
                                sudo cp temp-file.yaml  $FILE
                                sudo yq eval '(.spec.rules[0] | select(.host == "$ING_HOST")).host |= "   " + .' $FILE
                                cat $FILE
                                sudo rm -f temp-file.yaml
                                sudo rm -f 1
                                cd ../../
                                sed -i 's/image: \$PREG\/docker-base-images\/kuberunner:v1/image: \$PREG\/docker-base-images\/kuberunner:v2/g' .gitlab-ci.yml
                                #sudo git add .
                                #sudo git commit -am "change ingress version and gitlab-ci kubrunner"
                                #sudo git push -f origin change-ingress-version
                                #sudo git push -o merge_request.create

                            

                        else
                            echo "versionesh jadide nemikhad hooooraaaaaaaaaaaaa"
                            fi  
                   fi
                done   
        fi
            cd $CURRENT_DIRECTORY
    done
                echo "this project has ${#INGRESS_COUNT_ARRAY[@]} ingress files"
                INGRESS_COUNT_ARRAY=()
            
           
