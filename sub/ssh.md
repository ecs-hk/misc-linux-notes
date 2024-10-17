# SSH key magic

## Generate new keypair

### RSA

```bash
ssh-keygen -t rsa -a 100 -b 8192
```

### ED25519

```bash
ssh-keygen -t ed25519 -a 100
```

### ED25519 with FIDO non-resident credentials

* touch required [^ssh_key_passphrase_note]

```bash
ssh-keygen -t ed25519-sk -C "Yubi-W"
```

### ED25519 with FIDO resident credentials

* PIN required [^ssh_key_passphrase_note] [^yubi_example]

```bash
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "Yubi-SB"
```

[^ssh_key_passphrase_note]:
    For SSH keys that are created with a FIDO authenticator, a key passphrase may not be very useful. Instead, private key access can be managed using the physical device (with either touch or a PIN).

[^yubi_example]:
    FIDO example with resident credentials derived from [Yubikey article](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html).

## Display key signature and artwork

```bash
ssh-keygen -vl -f privkey
```

## Create a public key from a private key

```bash
ssh-keygen -y -f privkey > pubkey
```

## Change (or add) passphrase for private key

```bash
ssh-keygen -p -f privkey
```

## Convert OpenSSH private key to RSA private key

```bash
# This operation overwrites the privkey file
cp privkey privkey.openssh
ssh-keygen -p -N "" -m pem -f privkey
```

## Convert public key to Windows-friendly

You're not really using Windows, right? This is for your less-fortunate acquaintances.

```bash
ssh-keygen -e -m RFC4716 -f pubkey > pubkey.otherformat
```

# SSH tunneling

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
