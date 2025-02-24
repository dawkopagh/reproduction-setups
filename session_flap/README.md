## Reproduction steps for FRR issue: route withdrawal from kernel during 'bgp clear...'


### Instruction

1. Build the docker image, it uses frr-10.1.1 by default but you can tweak it to checkout on different tag, it builds and installs frr from source:<br>
`docker build -t frr-rs-flap:frr10.1.1 .`

2. Run setup script, it should run 1 hypervisor container, 3 route servers and one route injector, prepare interfaces, run respective daemons, load configs and inject kernel routes on route-injector box which will be readvertised to route-servers:<br>

3. Start interactive terminal session with hypervisor:<br>
`docker exec -it hypervisor bash`

4. Check if the session with routeserver1 is up `vtysh -c 'show bgp sum'` and if the routes have been instaled to kernel `ip r`

5. Run rtmon process to track if routes are being withdrawn from kernel:<br>
`rtmon -family inet route file $(hostname -s)_rtmon.log &`

6. Administratively clear BGP session with 2002:db8::2:<br>
`vtysh -c 'clear bgp 2001:db8::2'`

7. Read monitor file, you should see bunch of deletes and then installs into kernel after the session comes back up:<br>
`ip monitor fil $(hostname -s)_rtmon.log`