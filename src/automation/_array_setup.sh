
test -f $clusterfile

RED='\033[0;31m'
LGRN='\033[1;32m'
YLOW='\033[1;33m'
LBLU='\033[1;34m'
NC='\033[0m' # No Color

if [ $? -eq 0 ]
then
    cluster_data=$(<$clusterfile)

    nodename=$(echo $cluster_data | jq '.[] | select(.name | contains("NODENAME") ).name')

    if [ "$nodename" == "\"NODENAME\"" ]
    then
        printf "${RED}>> Cluster data file '_cluster.json' needs to be modified with the target cluster host names and IP addresses.${NC}\n\n"
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

printf " ${YLOW}Cluster Data: $cluster_data ${NC}\n\n"
