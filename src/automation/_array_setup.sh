
test -f $clusterfile

if [ $? -eq 0 ]
then
    cluster_data=$(<$clusterfile)

    nodename=$(echo $cluster_data | jq '.[] | select(.name | contains("NODENAME") ).name')

    if [ "$nodename" == "\"NODENAME\"" ]
    then
        printf ">> Cluster data file '_cluster.json' needs to be modified with the target cluster host names and IP addresses.\n\n"
        exit 1
    else
        printf "Cluster data file '_cluster.json' has been modified...proceeding.\n\n"
    fi
else

    printf ">> Could not find the file '$clusterfile'.  It is required input data for execution of this script.\n"

    exit 1
fi


ip_addr_me="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
printf "\nMy IP Address:$ip_addr_me\n"


length=$(cat _cluster.json | jq '. | length')
printf "Cluster Size: $length nodes.\n\n"

printf " Cluster Data: $cluster_data \n\n"
