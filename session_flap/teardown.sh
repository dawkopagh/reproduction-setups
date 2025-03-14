#!/bin/bash

containers=(hypervisor routeserver1 routeserver2 routeserver3 route_injector)

for container in "${containers[@]}"; do
    echo "Stopping container: $container"
    docker stop "$container"
    echo "Removing container: $container"
    docker rm "$container"
done

docker network rm frr_reprod

echo "Teardown complete."
