FILE_HOSTNAME="/etc/hostname"
FILE_HOSTS="/etc/hosts"
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

download_location="https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/"

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

