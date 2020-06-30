
# Valid time zones:  https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
zonelocation="America/Chicago"

#  /etc/locale
#  Valid locale codes:  cat /usr/share/i18n/SUPPORTED
orig_locale="en_GB.UTF-8 UTF-8"
new_locale="en_US.UTF-8 UTF-8"

#  Valid country codes for Keyboard layout (under "Current Codes" / "Alpha-2 code"): https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes
#  data held here:  /etc/default/keyboard
orig_keyboard="gb"
new_keyboard="us"


PLATFORM_PI="pi"
PLATFORM_UBUNTU="ubuntu"
ID_PI="pi"
ID_UBUNTU="ubuntu"
PASSWORD_PI="raspberry"
PASSWORD_UBUNTU="raspberry"

FILE_HOSTNAME="/etc/hostname"
FILE_HOSTS="/etc/hosts"
FILE_KUB_LIST_DATA="_kub_list.txt"
SYSCTL_FILE="sysctl.conf"
BAK_FILE="${SYSCTL_FILE}.BAK"
ETC_FOLDER="/etc/"
SED_REGEX_QUERY="s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/"
DOCKER_ETC_DIR="/etc/docker/"
BOOT_FOLDER="/boot/"
BOOT_FIRMWARE_FOLDER="/boot/firmware/"
CMDLINE_TXT_BACKUP="cmdline_backup.txt"
CMDLINE_TXT="cmdline.txt"
CGROUP=" cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
CGROUP_TEST="cgroup_enable"

localhostsfile="hosts.local"
localhostnamefile="hostname.local"
clusterfile="_cluster.json"
daemonjsonfile="_daemon.json"
daemondestfilename="/etc/docker/daemon.json"
kubeadminitdonefile="kubeadm_init.flg"
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

print_warning () {

    printf "${YLOW}${@}${NC}\n"
}

print_result () {

    if [ $1 -ne 0 ]; then
        print_instruction "$RED..Issue detected.$NC\n"
    else
        print_instruction "$GRN..Succeeded.$NC\n"
    fi
}


get_ip_host_and_platform() {

    ip_target=$(echo $cluster_data | jq --raw-output ".[$1].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$1].name")
    platform_target=$(echo $cluster_data | jq --raw-output ".[$1].platform")

    if [ $platform_target == $PLATFORM_PI ]
    then
        piid="$ID_PI"
        pword="$PASSWORD_PI"
    else
        piid="$ID_UBUNTU"
        pword="$PASSWORD_UBUNTU"
    fi

    print_instruction "Processing $host_target/$ip_target/$platform_target:"

    print_instruction "Processing $piid/$pword:"
}



# execute_command -r|-l -1|-R "command string"
execute_command() {

    local -r -i max_attempts=3
    local -i attempt_num=1

    if [ "$2" == "-1" ]; then
        if  [ "$1" == "-l" ]; then
            eval "$3"
        else
            sudo sshpass -p $pword ssh $piid@$ip_target "$3"
        fi
    else

        if [ "$1" == "-l" ]; then

            # Local Call
            until eval "$3"
            do
                if (( attempt_num == max_attempts )); then
                    print_instruction "Attempt $attempt_num failed and there are no more attempts."
                    return 1
                else
                    print_instruction "Attempting to execute command.  This is attempt $attempt_num."
                    (( attempt_num++ ))
                    eval "$3"

                    return $?
                fi
            done

        else

            # Remote Call
            until sudo sshpass -p $pword ssh $piid@$ip_target "$3"
            do
                if (( attempt_num == max_attempts ))
                then
                    print_instruction "Attempt $attempt_num failed and there are no more attempts."
                    return 1
                else
                    print_instruction "Attempting to execute command.  This is attempt $attempt_num."
                    (( attempt_num++ ))
                    sudo sshpass -p $pword ssh $piid@$ip_target "$3"

                    return $?
                fi
            done

        fi
    fi
}



install_and_validate_package() {
    local -r -i max_attempts=5
    local -i attempt_num=1

    until execute_command $1 -1 "dpkg-query -W -f='${Status}\n' $2 > /dev/null 2>&1"
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempting to install package: $2  This is attempt $attempt_num."
            (( attempt_num++ ))
            execute_command $1 -1 "sudo apt-get install -y $2"
        fi
    done
}


update_locale_setting() {

    # $1: setting
    # $2: value
    # $3: (-r - remote call | -l - local call)

    execute_command $3 -1 "grep "'"'"export $1="'"'" /home/$piid/.bashrc &> /dev/null"

    if [ $? -ne 0 ]
    then
        print_instruction "Add $1 setting with $2 to .bashrc..."
            execute_command $3 -1 "echo "'"'"export $1=$2"'"'" >> /home/$piid/.bashrc"
            execute_command $3 -1 "source /home/$piid/.bashrc"
        print_result $?
    fi

}


