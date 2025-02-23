#! /bin/bash

docker network create --ipv6 --subnet 2001:db8::/64 frr_reprod
docker run -d --privileged --name hypervisor --network frr_reprod --ip6 2001:db8::5 frr-graceful-restart:frr10.1.1
docker run -d --privileged --name routeserver1 --network frr_reprod --ip6 2001:db8::2 frr-graceful-restart:frr10.1.1

docker cp frr-hypervisor.conf hypervisor:/
docker cp frr-routeserver1.conf routeserver1:/
docker cp setup_vrf_hypervisor.sh hypervisor:/root/setup_vrf.sh
docker cp setup_vrf_routeserver1.sh routeserver1:/root/setup_vrf.sh
docker cp inject_routes.sh routeserver1:/root/inject_routes.sh

for container in hypervisor routeserver1; do
	docker exec -it "$container" sh -c '/usr/sbin/zebra -d && /usr/sbin/bgpd -d && /usr/sbin/staticd -d && /usr/sbin/mgmtd -d'
    	docker exec -it "$container" sh -c "vtysh -f /frr-${container}.conf"
	docker exec -it "$container" sh -c "/root/setup_vrf.sh"
done

docker exec -it routeserver1 sh -c "/root/inject_routes.sh"
