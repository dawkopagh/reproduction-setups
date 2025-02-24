#! /bin/bash

docker network create --ipv6 --subnet 2001:db8::/64 frr_reprod
docker run -d --privileged --name hypervisor --network frr_reprod --ip6 2001:db8::5 frr-rs-flap:frr10.1.1
docker run -d --privileged --name routeserver1 --network frr_reprod --ip6 2001:db8::2 frr-rs-flap:frr10.1.1
docker run -d --privileged --name routeserver2 --network frr_reprod --ip6 2001:db8::3 frr-rs-flap:frr10.1.1
docker run -d --privileged --name routeserver3 --network frr_reprod --ip6 2001:db8::4 frr-rs-flap:frr10.1.1
docker run -d --privileged --name route_injector --network frr_reprod --ip6 2001:db8::10 frr-rs-flap:frr10.1.1

docker cp frr-hypervisor.conf hypervisor:/
docker cp setup_vrf_hypervisor.sh hypervisor:/root/setup_vrf.sh

docker cp frr-routeserver1.conf routeserver1:/
docker cp setup_vrf_routeserver1.sh routeserver1:/root/setup_vrf.sh

docker cp frr-routeserver2.conf routeserver2:/
docker cp setup_vrf_routeserver2.sh routeserver2:/root/setup_vrf.sh

docker cp frr-routeserver3.conf routeserver3:/
docker cp setup_vrf_routeserver3.sh routeserver3:/root/setup_vrf.sh

docker cp frr-route_injector.conf route_injector:/
docker cp setup_vrf_route_injector.sh route_injector:/root/setup_vrf.sh
docker cp inject_routes.sh route_injector:/root/inject_routes.sh

for container in hypervisor routeserver1 routeserver2 routeserver3 route_injector; do
	docker exec -it "$container" sh -c '/usr/sbin/zebra -d && /usr/sbin/bgpd -d && /usr/sbin/staticd -d && /usr/sbin/mgmtd -d'
    	docker exec -it "$container" sh -c "vtysh -f /frr-${container}.conf"
	docker exec -it "$container" sh -c "/root/setup_vrf.sh"
done

docker exec -it route_injector sh -c "/root/inject_routes.sh"
