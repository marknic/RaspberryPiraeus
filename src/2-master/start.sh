


ip_addr=$(cat update-hosts.sh | grep -Eo "?([0-9]*\.){3}[0-9]*.*$(hostname).*" | grep -Eo "([0-9]*\.){3}[0-9]*")

echo $ip_addr
