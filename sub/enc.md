# openssl

## Prepare new x509 cert

Generate private key:
```bash
openssl genrsa -out server.key 2048
```

Generate CSR:
```bash
openssl req -new -key server.key -out server.csr
```

Self-sign cert (or.. submit the CSR to your CA instead):
```bash
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.pem
```

## Inspect

View PEM cert contents:
```bash
openssl x509 -text -in server.pem
```

View issuer (intermediate CA) for cert:
```bash
openssl x509 -in server.pem -noout -subject -issuer -enddate
```

View cert on remote system:
```bash
openssl s_client -host somehost.local -port 443
```

View just the expiration date on remote system:
```bash
openssl s_client -host somehost.local -port 443 | openssl x509 -noout -dates
```

View CSR contents:
```bash
openssl req -text -noout -verify -in server.csr
```

## Verify

Verify cert chain:
```bash
openssl verify [-CAfile my-ca.pem] server.pem
```

Verify cert matches private key (via matching digest):
```bash
openssl x509 -noout -modulus -in server.pem | openssl sha1
openssl rsa -noout -modulus -in server.key | openssl sha1
```

## Create password digests

md5 digest:
```bash
openssl passwd -1 'nice.pass'
```

sha512 digest:
```bash
openssl passwd -salt xxyyzz -6 'nicer.pass'
```

## Create Java keystore

```bash
# First, convert PEM file and key to PKCS12 format
# (will prompt for a new PKCS12 password)
openssl pkcs12 \
  -export \
  -in server.pem \
  -inkey server.key \
  -certfile ca-cert.pem \
  -name 'some.host.local' \
  -out server.p12
```

```bash
# Next, convert PKCS12 file to JKS format
# (will prompt for the PKCS12 password)
keytool \
  -importkeystore \
  -srckeystore server.p12 \
  -destkeystore server.jks \
  -srcstoretype PKCS12 \
  -deststoretype JKS \
  -srcalias 'some.host.local' \
  -destalias 'some.host.local'
```

```bash
# Next, if needed add additional CA certs to JKS file
# (will prompt for the PKCS12 password)
keytool \
  -keystore server.jks \
  -import \
  -alias 'someotherca' \
  -trustcacerts \
  -file some-other-ca.pem
```

## View Java keystore

```bash
keytool -list -v -keystore server.jks -storepass 'JKS password'
```

# tcpdump

## Confirm encryption on the wire

Note: to capture the full packet payload, the `-s 0` option was required on older tcpdump versions. It is no longer necessary.

```bash
sudo tcpdump -i ens160 -nn -A port 3306 and host 10.69.80.2
```

## Save packet capture to file

```bash
sudo tcpdump -i ens160 -w foo port 3306 and host 10.69.80.2
```

## Read packet capture data from file

```bash
tcpdump -nn -A -r foo
```

# GNUPG

## Create a new keypair

```bash
gpg --full-gen-key --expert
```

## Import public key

```bash
# Example keyserver and key ID..
gpg --keyserver pgp.mit.edu --recv-keys 89ccae8b
```

## Back up and restore a keypair

This is a cleaner approach than exporting the public key, private key, and trustdb separately

```bash
gpg --list-secret-keys --keyid-format LONG

# Identify the email address associated with the keypair, and then:
gpg -o secret-keep-safe.gpg --export-options backup --export-secret-keys someguy@buz

# To restore the keypair:
gpg --import-options restore --import secret-keep-safe.gpg

# Set the trust level for the keypair:
gpg --edit-key someguy@buz
gpg> trust
# (enter 5)
gpg> quit
```

# Steganography

Both `steghide` and `outguess` are decent options.

```bash
steghide embed                          \
        -ef data-to-hide.txt            \
        -cf white-cloud.jpg             \
        -sf white-cloud-w-data.jpg      \
        -e serpent                      \
        -p 'strong.pass'
```

```bash
steghide extract                        \
        -sf white-cloud-w-data.jpg      \
        -p 'strong.pass'
```
