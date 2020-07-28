
test -f $clusterfile

if [ $? -eq 0 ]
then
    cluster_data=$(<$clusterfile)

    nodename=$(echo $cluster_data | jq '.[] | select(.name | contains("NODENAME") ).name')

    if [ "$nodename" == "\"NODENAME\"" ]
    then
        printf "${RED}>> Cluster data file '_cluster.json' needs to be modified with the target cluster host names and IP addresses.${NC}\n\n"
        printf "${RED}>> Example: 'nano _cluster.json'${NC}\n"
        printf "${RED}>> When the cluster data file is configured to your environment, rerun this script. ${NC}\n\n"
        exit 1
    else
        printf "${LGRN}Cluster data file '_cluster.json' has been modified...proceeding.${NC}\n\n"
    fi
else

    printf "${RED}>> Could not find the file '$clusterfile'.  It is required input data for execution of this script.${NC}\n"

    exit 1
fi


ip_addr_me="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
printf "\nMy IP Address:$ip_addr_me\n"


length=$(cat _cluster.json | jq '. | length')
printf "Cluster Size: $length nodes.\n\n"

printf " ${YLOW}Cluster Data: $cluster_data \n${NC}\n\n"

printf "${YLOW}Initialize ID (Master)\n"
get_ip_host_and_platform 0
