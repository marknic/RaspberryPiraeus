zonelocation="America/Chicago"

FILE_HOSTNAME="/etc/hostname"
FILE_HOSTS="/etc/hosts"
FILE_KUB_LIST_DATA="_kub_list.txt"
SYSCTL_FILE="sysctl.conf"
BAK_FILE="${SYSCTL_FILE}.BAK"
ETC_FOLDER="/etc/"
SED_REGEX_QUERY="s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/"
DOCKER_ETC_DIR="/etc/docker/"
CMDLINE_TXT_BACKUP="/boot/cmdline_backup.txt"
CMDLINE_TXT="/boot/cmdline.txt"
CGROUP=" cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
CGROUP_TEST="cgroup_enable"
piid="pi"
pword="raspberry"
localhostsfile="hosts.local"
localhostnamefile="hostname.local"
clusterfile="_cluster.json"
daemonjsonfile="_daemon.json"
daemondestfilename="/etc/docker/daemon.json"
resolveconf="resolv.conf"

download_location="https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/"
kub_list="/etc/apt/sources.list.d/kubernetes.list"

RED='\033[1;31m'
GRN='\033[0;32m'

CYAN='\033[1;36m' # This is actually "light cyan"
LGRN='\033[1;32m'
YLOW='\033[1;33m'
LBLU='\033[1;34m'

NC='\033[0m' # No Color

print_instruction () {

    printf "${CYAN}${@}${NC}\n"
}

print_result () {

    if [ $1 -ne 0 ]; then
        print_instruction "$RED..Issue detected.$NC\n"
    else
        print_instruction "$GRN..Succeeded.$NC\n"
    fi
}

execute_remote_command_with_retry() {
    local -r -i max_attempts=3
    local -i attempt_num=1

    until sudo sshpass -p $pword ssh $piid@$ip_target $1
    do
        if (( attempt_num == max_attempts ))
        then
            print_instruction "Attempt $attempt_num failed and there are no more attempts."
            return 1
        else
            print_instruction "Attempting to execute command.  This is attempt $attempt_num."
            (( attempt_num++ ))
            sudo sshpass -p $pword ssh $piid@$ip_target $1
        fi
    done
}

execute_command_with_retry() {
    local -r -i max_attempts=3
    local -i attempt_num=1

    until eval $1
    do
        if (( attempt_num == max_attempts ))
        then
            print_instruction "Attempt $attempt_num failed and there are no more attempts."
            return 1
        else
            print_instruction "Attempting to execute command.  This is attempt $attempt_num."
            (( attempt_num++ ))
            eval $1
        fi
    done
}
