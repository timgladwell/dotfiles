
# directories on line 15/16 need to be created first
# /mnt/data/scripts/upd_pihole.sh

echo Pull latest pihole image
podman pull pihole/pihole:latest
echo Stop existing pihole container
podman stop pihole
echo Delete existing pihole container
podman rm pihole
echo Start new pihole container
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="America/Toronto" \
    -v "/mnt/data/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --dns=1.1.1.1 \
    --dns=1.0.0.1 \
    --hostname pi.hole \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e ServerIP="192.168.5.2" \
    -e IPv6="False" \
    pihole/pihole:latest
echo Reset pihole admin password
podman exec -it pihole pihole -a -p