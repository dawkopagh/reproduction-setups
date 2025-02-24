#!/bin/bash

IFACE="vrfv3"
NEXT_HOP="192.168.9.11"
START="192.168.9.100"  # Starting IP for the routes

# Function to convert an IPv4 address to an integer
ip2int() {
  local a b c d
  IFS=. read -r a b c d <<< "$1"
  echo $(( (a << 24) + (b << 16) + (c << 8) + d ))
}

# Function to convert an integer back to an IPv4 address
int2ip() {
  local ui32=$1
  local a=$(( (ui32 >> 24) & 0xFF ))
  local b=$(( (ui32 >> 16) & 0xFF ))
  local c=$(( (ui32 >> 8) & 0xFF ))
  local d=$(( ui32 & 0xFF ))
  echo "$a.$b.$c.$d"
}

start_int=$(ip2int "$START")

echo "Injecting kernel routes for EVPN advertisement with next-hop ${NEXT_HOP}..."

# Loop to add 1,000 routes
for ((i=0; i<1000; i++)); do
    current_int=$(( start_int + i ))
    prefix="$(int2ip "$current_int")/32"
    ip route add "$prefix" via "$NEXT_HOP" dev "$IFACE"
    if [ $? -eq 0 ]; then
        echo "Added route $prefix via next-hop ${NEXT_HOP} on interface ${IFACE}"
    else
        echo "Failed to add route $prefix"
    fi
done

echo "Done injecting routes."

