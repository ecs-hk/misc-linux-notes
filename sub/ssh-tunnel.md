# SSH tunnel recipes

## Port forward

In this example:
* Host A: Linux system running sshd
* Host B: Linux system running MariaDB; accessible only from the network Host A is on
* Laptop C: Client laptop

```bash
# Start port forwarding
[baz@laptop-c ~]$ ssh -Llocalhost:9090:host-b:3306 baz@host-a

# Connect to MariaDB using laptop client software
[baz@laptop-c ~]$ mysql -h localhost -P 9090 -u dba -p
```

## Dynamic HTTP proxy

In this example:
* Host A: Linux system running sshd
* Laptop B: Client laptop

```bash
# Start dynamic port forwarding
[baz@laptop-b ~]$ ssh -D localhost:8080 -C baz@host-a
```

Then configure web browser to use proxy.

1. Select "Manual proxy configuration"
2. Enter "SOCKS Host" values of: localhost, port 8080
3. Do not select "Use this proxy server for all protocols"
4. Leave the other Proxy input boxes blank
5. Select "SOCKS v5"
6. Select "Proxy DNS when using SOCKS v5"

(Now that the proxying is set up, all HTTP - and DNS - requests through the browser will be forwarded over SSH, through host-a, then on to their destination.)

## Reverse tunnel

Allows shell access to a system that is behind a NAT/PAT device. In this example:

* Host A: Linux system running sshd; on private LAN, behind NAT device
* Host B: Linux system running sshd; accessible from anywhere

```bash
# Start reverse tunnel
[foo@host-a ~]$ ssh -R 6900:localhost:22 bar@host-b

# Connect to "unreachable" system through reverse tunnel
[bar@host-b ~]$ ssh foo@localhost -p 6900
```
